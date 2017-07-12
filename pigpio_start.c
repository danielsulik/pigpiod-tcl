_wrap_pigpio_start(ClientData clientData SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  char *arg1 = (char *) 0 ;
  char *arg2 = (char *) 0 ;
  int res1 ;
  char *buf1 = 0 ;
  int alloc1 = 0 ;
  int res2 ;
  char *buf2 = 0 ;
  int alloc2 = 0 ;
  int result;

  if (SWIG_GetArgs(interp, objc, objv,"oo:pigpio_start ip port",(void *)0,(void *)0) == TCL_ERROR) SWIG_fail;
  res1 = SWIG_AsCharPtrAndSize(objv[1], &buf1, NULL, &alloc1);
  if (!SWIG_IsOK(res1)) {
    SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "pigpio_start" "', argument " "1"" of type '" "char *""'");
  }
  arg1 = (char *)(buf1);
  res2 = SWIG_AsCharPtrAndSize(objv[2], &buf2, NULL, &alloc2);
  if (!SWIG_IsOK(res2)) {
    SWIG_exception_fail(SWIG_ArgError(res2), "in method '" "pigpio_start" "', argument " "2"" of type '" "char *""'");
  }
  arg2 = (char *)(buf2);
  if (0 == strcmp (buf1, "0"))
  {
      arg1 = 0;
  }
  if (0 == strcmp (buf2, "0"))
  {
      arg2 = 0;
  }
  result = (int)pigpio_start(arg1,arg2);

  Tcl_SetObjResult(interp,SWIG_From_int((int)(result)));
  if (alloc1 == SWIG_NEWOBJ) free((char*)buf1);
  if (alloc2 == SWIG_NEWOBJ) free((char*)buf2);
  return TCL_OK;
fail:
  if (alloc1 == SWIG_NEWOBJ) free((char*)buf1);
  if (alloc2 == SWIG_NEWOBJ) free((char*)buf2);
  return TCL_ERROR;
}
