#define customloop_dll
// customloop_dll(dll)

global.customloopdll=argument0;
global.customloopinit=external_define(global.customloopdll,'Init',dll_stdcall,ty_real,1,ty_real);
global.customloopfree=external_define(global.customloopdll,'Free',dll_stdcall,ty_real,0);
global.customloopstep=external_define(global.customloopdll,'Step',dll_stdcall,ty_real,0);
global.customloopwait=external_define(global.customloopdll,'Wait',dll_stdcall,ty_real,10,ty_real,ty_real,ty_real,ty_real,ty_real,ty_real,ty_real,ty_real,ty_real,ty_real);
global.customloopread=external_define(global.customloopdll,'Read',dll_stdcall,ty_real,0);
global.customlooploop=external_define(global.customloopdll,'Loop',dll_stdcall,ty_real,0);
global.customloopdrop=external_define(global.customloopdll,'Drop',dll_stdcall,ty_real,1,ty_real);
global.customloopkeyboard[512]=0;




#define customloop_start
// customloop_start()

external_call(global.customloopinit,window_handle());


#define customloop_end
// customloop_end()

external_call(global.customloopfree);


#define customloop_close
// customloop_close()

customloop_end();
external_free(global.customloopdll);



#define customloop_timers
// customloop_timers([1,2,3,...10])

external_call(global.customloopwait,
argument0,argument1,argument2,argument3,argument4,
argument5,argument6,argument7,argument8,argument9);


#define customloop_wait
// timer=customloop_wait()

return external_call(global.customloopstep);


#define customloop_drop
// timer=customloop_drop(index)

return external_call(global.customloopdrop,argument0);


#define customloop_userio
// customloop_userio()

// X = mouse_x (for window); //
// Y = mouse_y (for window); //
// K = keyboard_key (1..512); //
// (don't use V,M,B) //
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */var V,M,K,X,Y,B;external_call(global.customlooploop);while 1{V=external_call(global.customloopread);if V<0 break;M=(V>>30)&3;B=(V>>28)&3;if M=3{if B=0{K=V&$1ff;if V&$200!=0{
// keyboard up //
begin
global.customloopkeyboard[K]=0;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */}else{
// keyboard down //
begin
global.customloopkeyboard[K]+=1;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */}}else switch V&$f{case 0:
// window close //
begin
event_perform(ev_other,ev_close_button);
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 1:
// minimize //
begin

end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 2:
// maximize //
begin

end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 3:
// restore //
begin

end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */}}else{Y=(V>>14)&$3fff;X=V&$3fff;
// adjust point //
begin

end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */switch B{case 0:switch M{case 0:
// mouse move //
begin
mouse_mX=X+mofx;
mouse_mY=Y+mofy;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 1:
// wheel down //
begin

end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 2:
// wheel up //
begin

end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */}break case 1:switch M{case 0:
// left released //
begin
global.customloopkeyboard[mb_left]=0;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 1:
// left pressed //
begin
global.customloopkeyboard[mb_left]+=1;
event_perform(ev_mouse,ev_left_press);
mouse_X=X+mofx;
mouse_Y=Y+mofy;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 2:
// left double //
begin
global.customloopkeyboard[mb_left]+=1;
event_perform(ev_mouse,ev_left_press);
mouse_X=X+mofx;
mouse_Y=Y+mofy;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */}break case 2:switch M{case 0:
// right released //
begin
global.customloopkeyboard[mb_right]=0;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 1:
// right pressed //
begin
global.customloopkeyboard[mb_right]+=1;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 2:
// right double //
begin
global.customloopkeyboard[mb_right]+=1;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */}break case 3:switch M{case 0:
// middle released //
begin
global.customloopkeyboard[mb_middle]=0;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 1:
// middle pressed //
begin
global.customloopkeyboard[mb_middle]=1;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */break case 2:
// middle double //
begin
global.customloopkeyboard[mb_middle]+=1;
end;
/*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   */}}}}



#define customloop_keyboard
// state=customloop_keyboard(key,ext_also)
// 0 = released, 1 = just pressed, 1+ = hold

if argument1 return global.customloopkeyboard[argument0]+global.customloopkeyboard[argument0|256];
return global.customloopkeyboard[argument0];


