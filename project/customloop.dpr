library customloop;

uses
  SysUtils,
  Classes,
  Windows,
  Messages,
  MMSystem;

type
  TWindowProc = function(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): Integer; stdcall;

const
  MaxTimer = 9;

var
  Inited: Boolean = False;
  OldWinProc: Integer = 0;
  MyHandle: HWND;
  NextTime, FpsCnt: array[0..MaxTimer] of Double;
  Timers: Integer;

const
  Size = 1024;

var
  Event: array[0..Size - 1] of Cardinal;
  Head: Integer = 0;
  Tail: Integer = 0;

function Push(): Integer;
begin
  Result := Head;
  Inc(Head);
  if Head = Size then
    Head := 0;
  if Head = Tail then
  begin
    Inc(Tail);
    if Tail = Size then
      Tail := 0;
  end;
end;

function Pop(): Integer;
begin
  Result := -1;
  if Tail = Head then
    Exit;
  Result := Tail;
  Inc(Tail);
  if Tail = Size then
    Tail := 0;
end;

procedure AddMouseEvent(lParam: LPARAM; Button: Integer; Mode: Integer);
begin
  Event[Push()] := (lParam and $3fff) or ((lParam and $3fff0000) shr 2) or ((Button and 3) shl 28) or ((Mode and 3) shl 30);
end;

procedure AddKeyboardEvent(Key: Integer; lParam: LPARAM; Up: Boolean);
begin
  if Up then
    Event[Push()] := Integer($c0000200) or Integer(Key) or (((lParam shr 24) and 1) shl 8)
  else if (lParam and (1 shl 30)) <> 0 then
    Exit
  else
    Event[Push()] := Integer($c0000000) or Integer(Key) or (((lParam shr 24) and 1) shl 8);
end;

procedure AddSystemEvent(ev: Integer);
begin
  Event[Push()] := Integer($f0000000) or ev;
end;

function MyWindowProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): Integer; stdcall;
var
  Point: TPoint;
  Key: Integer;
begin
  case uMsg of
    WM_LBUTTONUP:
      AddMouseEvent(lParam, 1, 0);
    WM_LBUTTONDOWN:
      AddMouseEvent(lParam, 1, 1);
    WM_LBUTTONDBLCLK:
      AddMouseEvent(lParam, 1, 2);
    WM_RBUTTONUP:
      AddMouseEvent(lParam, 2, 0);
    WM_RBUTTONDOWN:
      AddMouseEvent(lParam, 2, 1);
    WM_RBUTTONDBLCLK:
      AddMouseEvent(lParam, 2, 2);
    WM_MBUTTONUP:
      AddMouseEvent(lParam, 3, 0);
    WM_MBUTTONDOWN:
      AddMouseEvent(lParam, 3, 1);
    WM_MBUTTONDBLCLK:
      AddMouseEvent(lParam, 3, 2);
    WM_MOUSEMOVE:
      AddMouseEvent(lParam, 0, 0);
    WM_MOUSEWHEEL:
      begin
        Point.X := lParam and $ffff;
        Point.Y := (lParam shr 16) and $ffff;
        ScreenToClient(MyHandle, Point);
        if (wParam and $80000000) <> 0 then
          AddMouseEvent((Point.X and $ffff) or (Point.Y shl 16), 0, 1)
        else
          AddMouseEvent((Point.X and $ffff) or (Point.Y shl 16), 0, 2);
      end;
    WM_KEYDOWN:
      AddKeyboardEvent(wParam and 255, lParam, False);
    WM_SYSKEYDOWN:
      begin
        Key := wParam and 255;
        AddKeyboardEvent(Key, lParam, False);
        if (Key = VK_MENU) or (Key = VK_F10) then
        begin
          Result := -1;
          Exit;
        end;
      end;
    WM_KEYUP, WM_SYSKEYUP:
      AddKeyboardEvent(wParam and 255, lParam, True);
    WM_QUIT, WM_CLOSE:
      AddSystemEvent(0);
    WM_SYSCOMMAND:
      case wParam and $fff0 of
        SC_CLOSE:
          AddSystemEvent(0);
        SC_MINIMIZE:
          AddSystemEvent(1);
        SC_MAXIMIZE:
          AddSystemEvent(2);
        SC_RESTORE:
          AddSystemEvent(3);
      end;
//      AddKeyboardEvent(0, 4);
//    WM_ACTIVATEAPP:
//      AddKeyboardEvent(0, 5);
  end;
  Result := TWindowProc(OldWinProc)(hwnd, uMsg, wParam, lParam);
  if Result <> 0 then
    Result := DefWindowProc(hwnd, uMsg, wParam, lParam);
end;

function Loop(): Double; stdcall;
var
  msg: tagMSG;
begin
  Result := 0;
  while PeekMessage(msg, 0, 0, 0, PM_REMOVE) do
  begin
    if (msg.hwnd <> MyHandle) and ((msg.message and $ffff) = WM_SYSCOMMAND) then
      case msg.wParam and $fff0 of
        SC_CLOSE:
          AddSystemEvent(0);
        SC_MINIMIZE:
          AddSystemEvent(1);
        SC_MAXIMIZE:
          AddSystemEvent(2);
        SC_RESTORE:
          AddSystemEvent(3);
      end;
//    TranslateMessage(msg);
    DispatchMessage(msg);
  end;
end;

const
  GWLP_WNDPROC = -4;

function Step(): Double; stdcall;
var
  NewTime, Index, Idx: Integer;
  Cur, Min: Double;
begin
  Result := 0;
  if Timers >= 0 then
    repeat
      NewTime := Integer(timeGetTime());
      Idx := -1;
      Min := 0;
      for Index := 0 to Timers do
      begin
        Cur := NextTime[Index] - NewTime;
        if (Cur < Min) or (Idx = -1) then
        begin
          Min := Cur;
          Idx := Index;
        end;
      end;
      if Min <= 0 then
      begin
        NextTime[Idx] := NextTime[Idx] + FpsCnt[Idx];
        Result := Idx + 1;
        Break;
      end;
      Sleep(Round(Min / 2));
    until False;
end;

function Free(): Double; stdcall;
begin
  Result := 0;
  if not Inited then
    Exit;
  if OldWinProc <> 0 then
    SetWindowLong(MyHandle, GWLP_WNDPROC, OldWinProc);
  OldWinProc := 0;
  Inited := False;
end;

function Init(h: Double): Double; stdcall;
const
  ABOVE_NORMAL_PRIORITY_CLASS = $8000;
begin
  if Inited then
    Free();
  Result := 0;
  MyHandle := Round(h);
  OldWinProc := GetWindowLong(MyHandle, GWLP_WNDPROC);
  SetWindowLong(MyHandle, GWLP_WNDPROC, Integer(@MyWindowProc));
  Inited := True;
  SetPriorityClass(GetCurrentProcess(), ABOVE_NORMAL_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_TIME_CRITICAL - 1);
end;

function Wait(a, b, c, d, e, f, g, h, i, j: Double): Double; stdcall;
var
  NewTime, Index: Integer;
const
  msc = 1000.0;
begin
  Result := 0;
  Timers := 0;
  while True do
  begin
    if a <= 0 then
      break;
    FpsCnt[Timers] := msc / a;
    Inc(Timers);
    if b <= 0 then
      break;
    FpsCnt[Timers] := msc / b;
    Inc(Timers);
    if c <= 0 then
      break;
    FpsCnt[Timers] := msc / c;
    Inc(Timers);
    if d <= 0 then
      break;
    FpsCnt[Timers] := msc / d;
    Inc(Timers);
    if e <= 0 then
      break;
    FpsCnt[Timers] := msc / e;
    Inc(Timers);
    if f <= 0 then
      break;
    FpsCnt[Timers] := msc / f;
    Inc(Timers);
    if g <= 0 then
      break;
    FpsCnt[Timers] := msc / g;
    Inc(Timers);
    if h <= 0 then
      break;
    FpsCnt[Timers] := msc / h;
    Inc(Timers);
    if i <= 0 then
      break;
    FpsCnt[Timers] := msc / i;
    Inc(Timers);
    if j <= 0 then
      break;
    FpsCnt[Timers] := msc / j;
    Inc(Timers);
    Break;
  end;
  Dec(Timers);
  NewTime := Integer(timeGetTime());
  for Index := 0 to Timers do
    NextTime[Index] := NewTime + FpsCnt[Index];
end;

function Read(): Double; stdcall;
var
  Idx: Integer;
begin
  Result := -1;
  Idx := Pop();
  if Idx >= 0 then
    Result := Event[Idx];
end;

function Drop(i: Double): Double; stdcall;
var
  Index: Integer;
begin
  Result := 0;
  Index := Round(i) - 1;
  if (Index < 0) or (Index > Timers) then
    Exit;
  NextTime[Index] := Integer(timeGetTime()) + FpsCnt[Index];
end;

exports
  Init,
  Free,
  Wait,
  Read,
  Loop,
  Step,
  Drop;

begin
end.

