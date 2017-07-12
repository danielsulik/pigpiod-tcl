_wrap_spi_xfer(ClientData clientData SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  int arg1 ;
  unsigned int arg2 ;
  unsigned int arg5 ;
  int val1 ;
  int ecode1 = 0 ;
  unsigned int val2 ;
  int ecode2 = 0 ;
  char *buf3 = 0 ;
  int alloc3 = 0 ;
  unsigned int val5 ;
  int ecode5 = 0 ;
  int result;
  char *rxBuf = 0;

  if (SWIG_GetArgs(interp, objc, objv,"oooo:spi_xfer pi handle txBuf count ",(void *)0,(void *)0,(void *)0,(void *)0) == TCL_ERROR) SWIG_fail;
  ecode1 = SWIG_AsVal_int SWIG_TCL_CALL_ARGS_2(objv[1], &val1);
  if (!SWIG_IsOK(ecode1)) {
    SWIG_exception_fail(SWIG_ArgError(ecode1), "in method '" "spi_xfer" "', argument " "1"" of type '" "int""'");
  }
  arg1 = (int)(val1);
  ecode2 = SWIG_AsVal_unsigned_SS_int SWIG_TCL_CALL_ARGS_2(objv[2], &val2);
  if (!SWIG_IsOK(ecode2)) {
    //SWIG_exception_fail(SWIG_ArgError(ecode2), "in method '" "spi_xfer" "', argument " "2"" of type '" "unsigned int""'");
  }
  arg2 = (unsigned int)(val2);
  ecode5 = SWIG_AsVal_unsigned_SS_int SWIG_TCL_CALL_ARGS_2(objv[4], &val5);
  if (!SWIG_IsOK(ecode5)) {
    SWIG_exception_fail(SWIG_ArgError(ecode5), "in method '" "spi_xfer" "', argument " "5"" of type '" "unsigned int""'");
  }
  arg5 = (unsigned int)(val5);

  char *txBuf = (char*) Tcl_GetByteArrayFromObj (objv[3], (int*) &val5);

  rxBuf = (char*) malloc (sizeof(char) * arg5);
  if (NULL == rxBuf)
  {
      SWIG_exception_fail(SWIG_ArgError(ecode1), "in method '" "spi_xfer" "', can't allocate read buffer");
  }

  result = (int)spi_xfer(arg1,arg2,txBuf,rxBuf,arg5);
  Tcl_SetObjResult(interp,SWIG_From_int((int)(result)));
  {
    Tcl_Obj *o = Tcl_NewByteArrayObj ((const unsigned char*)rxBuf,arg5);
    Tcl_ListObjAppendElement(interp,(Tcl_GetObjResult(interp)),o);
  }
  if (alloc3 == SWIG_NEWOBJ) free((char*)buf3);
  if (rxBuf) free (rxBuf);
  return TCL_OK;
fail:
  if (alloc3 == SWIG_NEWOBJ) free((char*)buf3);
  if (rxBuf) free (rxBuf);
  return TCL_ERROR;
}
