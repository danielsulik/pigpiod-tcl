gpioCallbackdummy (void) {}

typedef struct
{
    Tcl_Interp *interp;
    char       *procname;
    int         handle;
    int         init;
} callbackT;

static callbackT cbs[PI_MAX_USER_GPIO + 1];

void gpioCallbackInit (void)
{
    memset (cbs, 0, sizeof (cbs));
}

static void OnChangeCallback (int pi, unsigned gpio, unsigned level, uint32_t tick, void * user)
{
    callbackT *p = (callbackT *) user;
    size_t s     = strlen(p->procname);

    /* + 36 to accomodate 3 x unsigned + 3 spaces + traling zero */
    unsigned len = s  + 36 + 3 + 1;
    char *tmp    = (char*) malloc (sizeof(char) * len);
    snprintf (tmp, (sizeof(char) * len),"%s %u %u %u\n", p->procname, gpio, level, tick);
    fprintf  (stderr, "%s", tmp);

#if 0
    /*
     * This is not thread safe
     */
    Tcl_Eval (p->interp, (const char*)tmp);
#endif
    free     (tmp);
}

static int gpioCallbackRegister (int pi, unsigned gpio, unsigned edge, char *procname, Tcl_Interp *interp)
{
    cbs[gpio].init     = 1;
    cbs[gpio].interp   = interp;
    cbs[gpio].procname = (char *) malloc (strlen(procname) * (sizeof(char)) + 1);
    if (NULL == cbs[gpio].procname) return SWIG_ERROR;

    strncpy (cbs[gpio].procname, procname, strlen(procname) + 1);
    fprintf (stdout, "Callback registered: %s gpio:%d edge:%s\n",
             cbs[gpio].procname,
             gpio,
             (edge == RISING_EDGE)  ? "r" :
             (edge == FALLING_EDGE) ? "f" : "e");

    cbs[gpio].handle = callback_ex (pi, gpio, edge, OnChangeCallback, &cbs[gpio]);
    return cbs[gpio].handle;
}

_wrap_gpioCallback(ClientData clientData SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  int arg1 ;
  unsigned int arg2 ;
  unsigned int arg3 ;
  char *arg4 = (char *) 0 ;
  void *arg5 = (void *) 0 ;
  int val1 ;
  int ecode1 = 0 ;
  unsigned int val2 ;
  int ecode2 = 0 ;
  unsigned int val3 ;
  int ecode3 = 0 ;
  int res4 ;
  char *buf4 = 0 ;
  int alloc4 = 0 ;
  int res5 ;
  int result;

  if (SWIG_GetArgs(interp, objc, objv,"ooooo:gpioCallback pi user_gpio edge proc userdata ",(void *)0,(void *)0,(void *)0,(void *)0,(void *)0) == TCL_ERROR) SWIG_fail;
  ecode1 = SWIG_AsVal_int SWIG_TCL_CALL_ARGS_2(objv[1], &val1);
  if (!SWIG_IsOK(ecode1)) {
    SWIG_exception_fail(SWIG_ArgError(ecode1), "in method '" "gpioCallback" "', argument " "1"" of type '" "int""'");
  }
  arg1 = (int)(val1);


  ecode2 = SWIG_AsVal_unsigned_SS_int SWIG_TCL_CALL_ARGS_2(objv[2], &val2);
  if (!SWIG_IsOK(ecode2)) {
    SWIG_exception_fail(SWIG_ArgError(ecode2), "in method '" "gpioCallback" "', argument " "2"" of type '" "unsigned int""'");
  }
  arg2 = (unsigned int)(val2);

  if (arg2 > PI_MAX_USER_GPIO) {
      SWIG_exception_fail(SWIG_ArgError(SWIG_ERROR), "in method '" "gpioCallback" "', argument " "2"" is out of range"); //FIXME
  }
  ecode3 = SWIG_AsVal_unsigned_SS_int SWIG_TCL_CALL_ARGS_2(objv[3], &val3);
  if (!SWIG_IsOK(ecode3)) {
    SWIG_exception_fail(SWIG_ArgError(ecode3), "in method '" "gpioCallback" "', argument " "3"" of type '" "unsigned int""'");
  }
  arg3 = (unsigned int)(val3);

  if (!((arg3 == RISING_EDGE)  ||
        (arg3 == FALLING_EDGE) ||
        (arg3 == EITHER_EDGE)))
  {
      SWIG_exception_fail(SWIG_ArgError(SWIG_ERROR), "in method '" "gpioCallback" "', argument " "3"" is out of range"); //FIXME
  }

  res4 = SWIG_AsCharPtrAndSize(objv[4], &buf4, NULL, &alloc4);
  if (!SWIG_IsOK(res4)) {
    SWIG_exception_fail(SWIG_ArgError(res4), "in method '" "gpioCallback" "', argument " "4"" of type '" "char *""'");
  }
  arg4 = (char *)(buf4);
  //res5 = SWIG_ConvertPtr(objv[5],SWIG_as_voidptrptr(&arg5), 0, 0);
  //if (!SWIG_IsOK(res5)) {
  //  SWIG_exception_fail(SWIG_ArgError(res5), "in method '" "gpioCallback" "', argument " "5"" of type '" "void *""'");
  //}
  result = (int)gpioCallbackRegister (arg1,arg2,arg3,arg4,interp);
  Tcl_SetObjResult(interp,SWIG_From_int((int)(result)));
  if (alloc4 == SWIG_NEWOBJ) free((char*)buf4);
  return TCL_OK;
fail:
  if (alloc4 == SWIG_NEWOBJ) free((char*)buf4);
  return TCL_ERROR;
}
