!>    @brief writes/add a additional line (1D) to a hdf5-file
!>    @param[in] NI resulting array dimension
!>    @param[in] NJ new line index
!>    @param[in] A new line, [dimension] < [NI,NJ]
!>    @param[in] A_name array name (ascii)
!>    @param[in] f_name hdf5 file name
      SUBROUTINE add_line(ni,nj,a,a_name,f_name)
#ifndef noHDF
        USE hdf5
        use mod_hdf5_vars, only: error
#endif
        IMPLICIT NONE

!      arrayname and filename
        character (len=*) :: a_name, f_name

        INTEGER ni, nj
        DOUBLE PRECISION a(ni)

#ifndef noHDF
!      File identifiers
        INTEGER (hid_t) file_id
!      Dataset identifier
        INTEGER (hid_t) dset_id
!      Datatype identifier
        INTEGER (hid_t) dtype_id

!      FileSpace identifier
        INTEGER (hid_t) filespace
!      DataSpace identifier
        INTEGER (hid_t) dataspace
#endif

!      Data buffers
#ifdef HDF6432
        INTEGER (kind=4) :: rank
#else
#ifdef HDF64
        INTEGER (kind=8) :: rank
#else
        INTEGER rank
#endif
#endif
        PARAMETER (rank=2)

#ifndef noHDF
        INTEGER (hsize_t) dims(rank)
        INTEGER (hsize_t) data_dims(7)
        INTEGER (hsize_t) data_offs(rank)
#endif

#ifndef noHDF
        IF (nj==1) THEN
          CALL write2_hdf5(ni,nj,a,a_name,f_name)
        ELSE IF (nj>1) THEN
          dims(1) = ni
          dims(2) = nj
          data_dims(1) = ni
          data_dims(2) = 1
          data_offs(1) = 0
          data_offs(2) = nj - 1

!        Reopen hdf5 file.
          CALL h5fopen_f(f_name,h5f_acc_rdwr_f,file_id,error, &
            h5p_default_f)
          CALL h5dopen_f(file_id,a_name,dset_id,error)
          IF (error/=0) THEN
            WRITE(*,'(5A)') 'error: no array "', a_name, &
              '" on the file "', f_name, '" !!!'
            STOP
          END IF
          CALL h5dget_type_f(dset_id,dtype_id,error)

!        Extend the array dimension.
          CALL h5dextend_f(dset_id,dims,error)

!        Select a hyperslab, setup offset and range.
          CALL h5dget_space_f(dset_id,filespace,error)
          CALL h5sselect_hyperslab_f(filespace,h5s_select_set_f, &
            data_offs,data_dims,error)

!        Define memory space, makes file space available.
          CALL h5screate_simple_f(rank,data_dims,dataspace,error)

!        Write 'A' to the hyperslab.
          CALL h5dwrite_f(dset_id,h5t_native_double,a,data_dims,error, &
            dataspace,filespace)

          IF (error/=0) THEN
            WRITE(*,'(5A)') &
              'error: can not append a line to the array "', a_name, &
              '" on the file "', f_name, '" !'
            STOP
          END IF

!        Close file and dataset identifiers.
          CALL h5sclose_f(dataspace,error)
          CALL h5sclose_f(filespace,error)
          CALL h5dclose_f(dset_id,error)
          CALL h5tclose_f(dtype_id,error)
          CALL h5fclose_f(file_id,error)
        END IF

#endif
        RETURN
      END
