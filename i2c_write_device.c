_wrap_i2c_write_device(ClientData clientData SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  int arg1 ;
  unsigned int arg2 ;
  unsigned int arg4 ;
  int val1 ;
  int ecode1 = 0 ;
  unsigned int val2 ;
  int ecode2 = 0 ;
  int res3 ;
  char *buf3 = 0 ;
  int alloc3 = 0 ;
  unsigned int val4 ;
  int ecode4 = 0 ;
  int result;

  if (SWIG_GetArgs(interp, objc, objv,"oooo:i2c_write_device pi handle txBuf count ",(void *)0,(void *)0,(void *)0,(void *)0) == TCL_ERROR) SWIG_fail;
  ecode1 = SWIG_AsVal_int SWIG_TCL_CALL_ARGS_2(objv[1], &val1);
  if (!SWIG_IsOK(ecode1)) {
    SWIG_exception_fail(SWIG_ArgError(ecode1), "in method '" "i2c_write_device" "', argument " "1"" of type '" "int""'");
  }
  arg1 = (int)(val1);
  ecode2 = SWIG_AsVal_unsigned_SS_int SWIG_TCL_CALL_ARGS_2(objv[2], &val2);
  if (!SWIG_IsOK(ecode2)) {
    SWIG_exception_fail(SWIG_ArgError(ecode2), "in method '" "i2c_write_device" "', argument " "2"" of type '" "unsigned int""'");
  }
  arg2 = (unsigned int)(val2);
  res3 = SWIG_AsCharPtrAndSize(objv[3], &buf3, NULL, &alloc3);
  if (!SWIG_IsOK(res3)) {
    SWIG_exception_fail(SWIG_ArgError(res3), "in method '" "i2c_write_device" "', argument " "3"" of type '" "char *""'");
  }
  ecode4 = SWIG_AsVal_unsigned_SS_int SWIG_TCL_CALL_ARGS_2(objv[4], &val4);
  if (!SWIG_IsOK(ecode4)) {
    SWIG_exception_fail(SWIG_ArgError(ecode4), "in method '" "i2c_write_device" "', argument " "4"" of type '" "unsigned int""'");
  }
  arg4 = (unsigned int)(val4);
  /*
   * Get pointer to binary tx buffer
   * SWIG does not do it correctly
   */
  char *txBuf = (char*)Tcl_GetByteArrayFromObj (objv[3], (int*)&val4);

  result = (int)i2c_write_device(arg1,arg2,txBuf,arg4);
  Tcl_SetObjResult(interp,SWIG_From_int((int)(result)));
  if (alloc3 == SWIG_NEWOBJ) free((char*)buf3);
  return TCL_OK;
fail:
  if (alloc3 == SWIG_NEWOBJ) free((char*)buf3);
  return TCL_ERROR;
}

