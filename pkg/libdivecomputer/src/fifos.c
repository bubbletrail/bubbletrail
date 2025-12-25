/*
 * Based on code in libdivecomputer
 */

#include <stdlib.h> // malloc, free
#include <string.h>	// strerror, strlen
#include <errno.h>	// errno
#include <unistd.h>	// open, close, read, write, getpid
#include <fcntl.h>	// fcntl, O_RDONLY, O_WRONLY, O_NONBLOCK
#include <sys/select.h>	// select
#include <sys/ioctl.h>	// ioctl
#include <sys/stat.h>	// mkfifo
#include <sys/types.h>	// pid_t
#include <stdio.h>	// snprintf

#ifndef FIONREAD
#include <sys/filio.h>
#endif

#include "fifos.h"

// libdivecomputer private headers
#include "../libdivecomputer-0.9.0/src/common-private.h"
#include "../libdivecomputer-0.9.0/src/context-private.h"
#include "../libdivecomputer-0.9.0/src/iostream-private.h"
#include "../libdivecomputer-0.9.0/src/platform.h"
#include "../libdivecomputer-0.9.0/src/timer.h"

static dc_status_t dc_fifos_set_timeout (dc_iostream_t *iostream, int timeout);
static dc_status_t dc_fifos_set_break (dc_iostream_t *iostream, unsigned int value);
static dc_status_t dc_fifos_set_dtr (dc_iostream_t *iostream, unsigned int value);
static dc_status_t dc_fifos_set_rts (dc_iostream_t *iostream, unsigned int value);
static dc_status_t dc_fifos_get_lines (dc_iostream_t *iostream, unsigned int *value);
static dc_status_t dc_fifos_get_available (dc_iostream_t *iostream, size_t *value);
static dc_status_t dc_fifos_configure (dc_iostream_t *iostream, unsigned int baudrate, unsigned int databits, dc_parity_t parity, dc_stopbits_t stopbits, dc_flowcontrol_t flowcontrol);
static dc_status_t dc_fifos_poll (dc_iostream_t *iostream, int timeout);
static dc_status_t dc_fifos_read (dc_iostream_t *iostream, void *data, size_t size, size_t *actual);
static dc_status_t dc_fifos_write (dc_iostream_t *iostream, const void *data, size_t size, size_t *actual);
static dc_status_t dc_fifos_ioctl (dc_iostream_t *iostream, unsigned int request, void *data, size_t size);
static dc_status_t dc_fifos_flush (dc_iostream_t *iostream);
static dc_status_t dc_fifos_purge (dc_iostream_t *iostream, dc_direction_t direction);
static dc_status_t dc_fifos_sleep (dc_iostream_t *iostream, unsigned int milliseconds);
static dc_status_t dc_fifos_close (dc_iostream_t *iostream);

typedef struct dc_fifos_t {
	dc_iostream_t base;
	/*
	 * File descriptors for the read and write FIFOs.
	 */
	int fd_read;
	int fd_write;
	int timeout;
	dc_timer_t *timer;
} dc_fifos_t;

static const dc_iostream_vtable_t dc_fifos_vtable = {
	sizeof(dc_fifos_t),
	dc_fifos_set_timeout, /* set_timeout */
	dc_fifos_set_break, /* set_break */
	dc_fifos_set_dtr, /* set_dtr */
	dc_fifos_set_rts, /* set_rts */
	dc_fifos_get_lines, /* get_lines */
	dc_fifos_get_available, /* get_available */
	dc_fifos_configure, /* configure */
	dc_fifos_poll, /* poll */
	dc_fifos_read, /* read */
	dc_fifos_write, /* write */
	dc_fifos_ioctl, /* ioctl */
	dc_fifos_flush, /* flush */
	dc_fifos_purge, /* purge */
	dc_fifos_sleep, /* sleep */
	dc_fifos_close, /* close */
};

static dc_status_t
syserror(int errcode)
{
	switch (errcode) {
	case EINVAL:
		return DC_STATUS_INVALIDARGS;
	case ENOMEM:
		return DC_STATUS_NOMEMORY;
	case ENOENT:
		return DC_STATUS_NODEVICE;
	case EACCES:
	case EBUSY:
		return DC_STATUS_NOACCESS;
	default:
		return DC_STATUS_IO;
	}
}

// Counter for generating unique FIFO names within a process.
static unsigned int dc_fifos_counter = 0;

dc_status_t
dc_fifos_create (dc_context_t *context, const char *directory, char **read_path, char **write_path)
{
	if (directory == NULL || read_path == NULL || write_path == NULL)
		return DC_STATUS_INVALIDARGS;

	*read_path = NULL;
	*write_path = NULL;

	pid_t pid = getpid();
	unsigned int counter = dc_fifos_counter++;

	// Calculate the required buffer size.
	// Format: directory/dc_fifo_<pid>_<counter>_read
	// Format: directory/dc_fifo_<pid>_<counter>_write
	size_t maxlen = strlen(directory) + 64; // Plenty of room for the suffix.

	char *rpath = (char *) malloc(maxlen);
	if (rpath == NULL) {
		SYSERROR (context, ENOMEM);
		return DC_STATUS_NOMEMORY;
	}

	char *wpath = (char *) malloc(maxlen);
	if (wpath == NULL) {
		SYSERROR (context, ENOMEM);
		free(rpath);
		return DC_STATUS_NOMEMORY;
	}

	int n = snprintf(rpath, maxlen, "%s/dc_fifo_%d_%u_read", directory, (int)pid, counter);
	if (n < 0 || (size_t)n >= maxlen) {
		free(rpath);
		free(wpath);
		return DC_STATUS_NOMEMORY;
	}

	n = snprintf(wpath, maxlen, "%s/dc_fifo_%d_%u_write", directory, (int)pid, counter);
	if (n < 0 || (size_t)n >= maxlen) {
		free(rpath);
		free(wpath);
		return DC_STATUS_NOMEMORY;
	}

	INFO (context, "Create: read=%s, write=%s", rpath, wpath);

	// Create the read FIFO.
	if (mkfifo(rpath, 0600) != 0) {
		int errcode = errno;
		SYSERROR (context, errcode);
		free(rpath);
		free(wpath);
		return syserror(errcode);
	}

	// Create the write FIFO.
	if (mkfifo(wpath, 0600) != 0) {
		int errcode = errno;
		SYSERROR (context, errcode);
		unlink(rpath); // Clean up the read FIFO.
		free(rpath);
		free(wpath);
		return syserror(errcode);
	}

	*read_path = rpath;
	*write_path = wpath;

	return DC_STATUS_SUCCESS;
}

dc_status_t
dc_fifos_open (dc_iostream_t **out, dc_context_t *context, const char *read_path, const char *write_path)
{
	dc_status_t status = DC_STATUS_SUCCESS;
	dc_fifos_t *device = NULL;

	if (out == NULL || read_path == NULL || write_path == NULL)
		return DC_STATUS_INVALIDARGS;

	INFO (context, "Open: read=%s, write=%s", read_path, write_path);

	// Allocate memory.
	device = (dc_fifos_t *) dc_iostream_allocate (context, &dc_fifos_vtable, DC_TRANSPORT_BLE);
	if (device == NULL) {
		SYSERROR (context, ENOMEM);
		return DC_STATUS_NOMEMORY;
	}

	// Initialize file descriptors to invalid.
	device->fd_read = -1;
	device->fd_write = -1;

	// Default to blocking reads.
	device->timeout = -1;

	// Create a high resolution timer.
	status = dc_timer_new (&device->timer);
	if (status != DC_STATUS_SUCCESS) {
		ERROR (context, "Failed to create a high resolution timer.");
		goto error_free;
	}

	// Open the read FIFO in non-blocking mode.
	device->fd_read = open (read_path, O_RDONLY | O_NONBLOCK);
	if (device->fd_read == -1) {
		int errcode = errno;
		SYSERROR (context, errcode);
		status = syserror (errcode);
		goto error_timer_free;
	}

	// Open the write FIFO in non-blocking mode.
	device->fd_write = open (write_path, O_WRONLY | O_NONBLOCK);
	if (device->fd_write == -1) {
		int errcode = errno;
		SYSERROR (context, errcode);
		status = syserror (errcode);
		goto error_close_read;
	}

	*out = (dc_iostream_t *) device;

	return DC_STATUS_SUCCESS;

error_close_read:
	close (device->fd_read);
error_timer_free:
	dc_timer_free (device->timer);
error_free:
	dc_iostream_deallocate ((dc_iostream_t *) device);
	return status;
}

static dc_status_t
dc_fifos_close (dc_iostream_t *abstract)
{
	dc_status_t status = DC_STATUS_SUCCESS;
	dc_fifos_t *device = (dc_fifos_t *) abstract;

	// Close the write FIFO.
	if (device->fd_write != -1) {
		if (close (device->fd_write) != 0) {
			int errcode = errno;
			SYSERROR (abstract->context, errcode);
			dc_status_set_error(&status, syserror (errcode));
		}
	}

	// Close the read FIFO.
	if (device->fd_read != -1) {
		if (close (device->fd_read) != 0) {
			int errcode = errno;
			SYSERROR (abstract->context, errcode);
			dc_status_set_error(&status, syserror (errcode));
		}
	}

	dc_timer_free (device->timer);

	return status;
}

static dc_status_t
dc_fifos_configure (dc_iostream_t *abstract, unsigned int baudrate, unsigned int databits, dc_parity_t parity, dc_stopbits_t stopbits, dc_flowcontrol_t flowcontrol)
{
	// FIFOs don't need serial configuration - just return success.
	(void)abstract;
	(void)baudrate;
	(void)databits;
	(void)parity;
	(void)stopbits;
	(void)flowcontrol;

	return DC_STATUS_SUCCESS;
}

static dc_status_t
dc_fifos_set_timeout (dc_iostream_t *abstract, int timeout)
{
	dc_fifos_t *device = (dc_fifos_t *) abstract;

	device->timeout = timeout;

	return DC_STATUS_SUCCESS;
}

static dc_status_t
dc_fifos_poll (dc_iostream_t *abstract, int timeout)
{
	dc_fifos_t *device = (dc_fifos_t *) abstract;
	int rc = 0;

	do {
		fd_set fds;
		FD_ZERO (&fds);
		FD_SET (device->fd_read, &fds);

		struct timeval tv, *ptv = NULL;
		if (timeout > 0) {
			tv.tv_sec  = (timeout / 1000);
			tv.tv_usec = (timeout % 1000) * 1000;
			ptv = &tv;
		} else if (timeout == 0) {
			tv.tv_sec  = 0;
			tv.tv_usec = 0;
			ptv = &tv;
		}

		rc = select (device->fd_read + 1, &fds, NULL, NULL, ptv);
	} while (rc < 0 && errno == EINTR);

	if (rc < 0) {
		int errcode = errno;
		SYSERROR (abstract->context, errcode);
		return syserror (errcode);
	} else if (rc == 0) {
		return DC_STATUS_TIMEOUT;
	} else {
		return DC_STATUS_SUCCESS;
	}
}

static dc_status_t
dc_fifos_read (dc_iostream_t *abstract, void *data, size_t size, size_t *actual)
{
	dc_status_t status = DC_STATUS_SUCCESS;
	dc_fifos_t *device = (dc_fifos_t *) abstract;

	// The absolute target time.
	dc_usecs_t target = 0;

	int init = 1;
	while (1) {
		fd_set fds;
		FD_ZERO (&fds);
		FD_SET (device->fd_read, &fds);

		struct timeval tv, *ptv = NULL;
		if (device->timeout > 0) {
			dc_usecs_t timeout = 0;

			dc_usecs_t now = 0;
			status = dc_timer_now (device->timer, &now);
			if (status != DC_STATUS_SUCCESS) {
				break;
			}

			if (init) {
				// Calculate the initial timeout.
				timeout = (dc_usecs_t) device->timeout * 1000;
				// Calculate the target time.
				target = now + timeout;
				init = 0;
			} else {
				// Calculate the remaining timeout.
				if (now < target) {
					timeout = target - now;
				} else {
					timeout = 0;
				}
			}
			tv.tv_sec  = timeout / 1000000;
			tv.tv_usec = timeout % 1000000;
			ptv = &tv;
		} else if (device->timeout == 0) {
			tv.tv_sec  = 0;
			tv.tv_usec = 0;
			ptv = &tv;
		}

		int rc = select (device->fd_read + 1, &fds, NULL, NULL, ptv);
		if (rc < 0) {
			int errcode = errno;
			if (errcode == EINTR)
				continue; // Retry.
			SYSERROR (abstract->context, errcode);
			status = syserror (errcode);
			break;
		} else if (rc == 0) {
			status = DC_STATUS_TIMEOUT;
			break; // Timeout.
		}

		ssize_t n = read (device->fd_read, (char *) data, size);
		if (actual)
			*actual = n;
		if (n > 0) {
			status = DC_STATUS_SUCCESS;
			break;
		}
		if (n < 0) {
			int errcode = errno;
			if (errcode == EINTR || errcode == EAGAIN)
				continue; // Retry.
			SYSERROR (abstract->context, errcode);
			status = syserror (errcode);
			break;
		} else if (n == 0) {
			status = DC_STATUS_TIMEOUT;
			break; // EOF.
		}
	}

	return status;
}

static dc_status_t
dc_fifos_write (dc_iostream_t *abstract, const void *data, size_t size, size_t *actual)
{
	dc_status_t status = DC_STATUS_SUCCESS;
	dc_fifos_t *device = (dc_fifos_t *) abstract;
	size_t nbytes = 0;

	while (nbytes < size) {
		fd_set fds;
		FD_ZERO (&fds);
		FD_SET (device->fd_write, &fds);

		int rc = select (device->fd_write + 1, NULL, &fds, NULL, NULL);
		if (rc < 0) {
			int errcode = errno;
			if (errcode == EINTR)
				continue; // Retry.
			SYSERROR (abstract->context, errcode);
			status = syserror (errcode);
			goto out;
		} else if (rc == 0) {
			break; // Timeout.
		}

		ssize_t n = write (device->fd_write, (const char *) data + nbytes, size - nbytes);
		if (n < 0) {
			int errcode = errno;
			if (errcode == EINTR || errcode == EAGAIN)
				continue; // Retry.
			SYSERROR (abstract->context, errcode);
			status = syserror (errcode);
			goto out;
		} else if (n == 0) {
			 break; // EOF.
		}

		nbytes += n;
	}

out:
	if (actual)
		*actual = nbytes;

	return status;
}

static dc_status_t
dc_fifos_ioctl (dc_iostream_t *abstract, unsigned int request, void *data, size_t size)
{
	// FIFOs don't support any special ioctls.
	(void)abstract;
	(void)request;
	(void)data;
	(void)size;

	return DC_STATUS_UNSUPPORTED;
}

static dc_status_t
dc_fifos_purge (dc_iostream_t *abstract, dc_direction_t direction)
{
	dc_fifos_t *device = (dc_fifos_t *) abstract;

	// For FIFOs, we can only really purge the input by reading and discarding.
	if (direction == DC_DIRECTION_INPUT || direction == DC_DIRECTION_ALL) {
		// Read and discard any available data.
		char buf[256];
		ssize_t n;
		do {
			n = read (device->fd_read, buf, sizeof(buf));
		} while (n > 0 || (n < 0 && errno == EINTR));

		// EAGAIN is expected when there's no more data.
		if (n < 0 && errno != EAGAIN) {
			int errcode = errno;
			SYSERROR (abstract->context, errcode);
			return syserror (errcode);
		}
	}

	// Output purge is a no-op for FIFOs (data is already in the pipe).
	return DC_STATUS_SUCCESS;
}

static dc_status_t
dc_fifos_flush (dc_iostream_t *abstract)
{
	// FIFOs don't need flushing - data is immediately available to the reader.
	(void)abstract;

	return DC_STATUS_SUCCESS;
}

static dc_status_t
dc_fifos_set_break (dc_iostream_t *abstract, unsigned int level)
{
	// FIFOs don't support break signals - just return success.
	(void)abstract;
	(void)level;

	return DC_STATUS_SUCCESS;
}

static dc_status_t
dc_fifos_set_dtr (dc_iostream_t *abstract, unsigned int level)
{
	// FIFOs don't have DTR - just return success.
	(void)abstract;
	(void)level;

	return DC_STATUS_SUCCESS;
}

static dc_status_t
dc_fifos_set_rts (dc_iostream_t *abstract, unsigned int level)
{
	// FIFOs don't have RTS - just return success.
	(void)abstract;
	(void)level;

	return DC_STATUS_SUCCESS;
}

static dc_status_t
dc_fifos_get_available (dc_iostream_t *abstract, size_t *value)
{
	dc_fifos_t *device = (dc_fifos_t *) abstract;

	int bytes = 0;
	if (ioctl (device->fd_read, FIONREAD, &bytes) != 0) {
		int errcode = errno;
		SYSERROR (abstract->context, errcode);
		return syserror (errcode);
	}

	if (value)
		*value = bytes;

	return DC_STATUS_SUCCESS;
}

static dc_status_t
dc_fifos_get_lines (dc_iostream_t *abstract, unsigned int *value)
{
	// FIFOs don't have modem lines - return all lines as inactive.
	(void)abstract;

	if (value)
		*value = 0;

	return DC_STATUS_SUCCESS;
}

static dc_status_t
dc_fifos_sleep (dc_iostream_t *abstract, unsigned int timeout)
{
	(void)abstract;

	if (dc_platform_sleep (timeout) != 0) {
		int errcode = errno;
		SYSERROR (abstract->context, errcode);
		return syserror (errcode);
	}

	return DC_STATUS_SUCCESS;
}
