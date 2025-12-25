/*
 * Based on code in libdivecomputer
 */

#ifndef DC_FIFOS_H
#define DC_FIFOS_H

#include <libdivecomputer/common.h>
#include <libdivecomputer/context.h>
#include <libdivecomputer/iostream.h>

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/**
 * Create a pair of FIFOs with unique names in the specified directory.
 *
 * The caller is responsible for freeing the returned path strings with free().
 * The caller should also remove the FIFOs when done using unlink() or remove().
 *
 * @param[in]   context    A valid context object.
 * @param[in]   directory  The directory in which to create the FIFOs.
 * @param[out]  read_path  A location to store the allocated read FIFO path.
 * @param[out]  write_path A location to store the allocated write FIFO path.
 * @returns #DC_STATUS_SUCCESS on success, or another #dc_status_t code
 * on failure.
 */
dc_status_t
dc_fifos_create (dc_context_t *context, const char *directory, char **read_path, char **write_path);

/**
 * Open a FIFO-based connection using a pair of named pipes.
 *
 * @param[out]  iostream   A location to store the FIFO connection.
 * @param[in]   context    A valid context object.
 * @param[in]   read_path  The path to the FIFO to read from.
 * @param[in]   write_path The path to the FIFO to write to.
 * @returns #DC_STATUS_SUCCESS on success, or another #dc_status_t code
 * on failure.
 */
dc_status_t
dc_fifos_open (dc_iostream_t **iostream, dc_context_t *context, const char *read_path, const char *write_path);

#ifdef __cplusplus
}
#endif /* __cplusplus */
#endif /* DC_FIFOS_H */
