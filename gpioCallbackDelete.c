_wrap_gpioCallbackDelete(ClientData clientData SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  unsigned int arg1 ;
  unsigned int val1 ;
  int ecode1 = 0 ;
  int result;

  if (SWIG_GetArgs(interp, objc, objv,"o:gpioCallbackDelete callback_id ",(void *)0) == TCL_ERROR) SWIG_fail;
  ecode1 = SWIG_AsVal_unsigned_SS_int SWIG_TCL_CALL_ARGS_2(objv[1], &val1);
  if (!SWIG_IsOK(ecode1)) {
    SWIG_exception_fail(SWIG_ArgError(ecode1), "in method '" "gpioCallbackDelete" "', argument " "1"" of type '" "unsigned int""'");
  }
  arg1 = (unsigned int)(val1);
  result = (int)callback_cancel(arg1);
  Tcl_SetObjResult(interp,SWIG_From_int((int)(result)));

  int i;
  for ( i = 0; i < PI_MAX_USER_GPIO + 1; i++)
  {
      if ((cbs[i].handle == arg1) && cbs[i].init)
      {
          cbs[i].init = 0;
          free (cbs[i].procname);
          cbs[i].procname = 0;
          break;
      }
  }
  return TCL_OK;
fail:
  return TCL_ERROR;
}
