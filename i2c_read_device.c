_wrap_i2c_read_device(ClientData clientData SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  int arg1 ;
  unsigned int arg2 ;
  unsigned int arg4 ;
  int val1 ;
  int ecode1 = 0 ;
  unsigned int val2 ;
  int ecode2 = 0 ;
  unsigned int val4 ;
  int ecode4 = 0 ;
  int result;

  char *rxBuf = 0;

  if (SWIG_GetArgs(interp, objc, objv,"ooo:i2c_read_device pi handle count ",(void *)0,(void *)0,(void *)0) == TCL_ERROR) SWIG_fail;
  ecode1 = SWIG_AsVal_int SWIG_TCL_CALL_ARGS_2(objv[1], &val1);
  if (!SWIG_IsOK(ecode1)) {
    SWIG_exception_fail(SWIG_ArgError(ecode1), "in method '" "i2c_read_device" "', argument " "1"" of type '" "int""'");
  }
  arg1 = (int)(val1);
  ecode2 = SWIG_AsVal_unsigned_SS_int SWIG_TCL_CALL_ARGS_2(objv[2], &val2);
  if (!SWIG_IsOK(ecode2)) {
    SWIG_exception_fail(SWIG_ArgError(ecode2), "in method '" "i2c_read_device" "', argument " "2"" of type '" "unsigned int""'");
  }
  arg2 = (unsigned int)(val2);
  ecode4 = SWIG_AsVal_unsigned_SS_int SWIG_TCL_CALL_ARGS_2(objv[3], &val4);
  if (!SWIG_IsOK(ecode4)) {
    SWIG_exception_fail(SWIG_ArgError(ecode4), "in method '" "i2c_read_device" "', argument " "4"" of type '" "unsigned int""'");
  }
  arg4 = (unsigned int)(val4);

  rxBuf = (char*) malloc (sizeof(char) * arg4);
  if (NULL == rxBuf)
  {
      SWIG_exception_fail(SWIG_ArgError(ecode1), "in method '" "i2c_read_device" "', can't allocate read buffer");
  }
  result = (int)i2c_read_device(arg1,arg2,rxBuf,arg4);
  Tcl_SetObjResult(interp,SWIG_From_int((int)(result)));
  {
    Tcl_Obj *o = Tcl_NewByteArrayObj ((const unsigned char*)rxBuf,arg4);
    Tcl_ListObjAppendElement(interp,(Tcl_GetObjResult(interp)),o);
  }
  if (rxBuf) free (rxBuf);
  return TCL_OK;
fail:
  if (rxBuf) free (rxBuf);
  return TCL_ERROR;
}

