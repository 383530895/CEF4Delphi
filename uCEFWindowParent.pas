// ************************************************************************
// ***************************** CEF4Delphi *******************************
// ************************************************************************
//
// CEF4Delphi is based on DCEF3 which uses CEF3 to embed a chromium-based
// browser in Delphi applications.
//
// The original license of DCEF3 still applies to CEF4Delphi.
//
// For more information about CEF4Delphi visit :
//         https://www.briskbard.com/index.php?lang=en&pageid=cef
//
//        Copyright � 2017 Salvador D�az Fau. All rights reserved.
//
// ************************************************************************
// ************ vvvv Original license and comments below vvvv *************
// ************************************************************************
(*
 *                       Delphi Chromium Embedded 3
 *
 * Usage allowed under the restrictions of the Lesser GNU General Public License
 * or alternatively the restrictions of the Mozilla Public License 1.1
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * Unit owner : Henri Gourvest <hgourvest@gmail.com>
 * Web site   : http://www.progdigy.com
 * Repository : http://code.google.com/p/delphichromiumembedded/
 * Group      : http://groups.google.com/group/delphichromiumembedded
 *
 * Embarcadero Technologies, Inc is not permitted to use or redistribute
 * this source code without explicit permission.
 *
 *)

unit uCEFWindowParent;

{$IFNDEF CPUX64}
  {$ALIGN ON}
  {$MINENUMSIZE 4}
{$ENDIF}

interface

uses
  WinApi.Windows, WinApi.Messages, System.Classes, Vcl.Controls,
  uCEFTypes, uCEFInterfaces;

type
  TCEFWindowParent = class(TWinControl)
    protected
      function  GetChildWindowHandle : THandle; virtual;

      procedure WndProc(var aMessage: TMessage); override;
      procedure Resize; override;

    public
      procedure UpdateSize;
      property  ChildWindowHandle : THandle   read GetChildWindowHandle;

    published
      property  Align;
      property  Anchors;
      property  Color;
      property  Constraints;
      property  TabStop;
      property  TabOrder;
      property  Visible;
  end;

implementation

uses
  uCEFMiscFunctions, uCEFClient, uCEFConstants;

function TCEFWindowParent.GetChildWindowHandle : THandle;
begin
  Result := GetWindow(Handle, GW_CHILD);
end;

procedure TCEFWindowParent.Resize;
begin
  inherited Resize;

  UpdateSize;
end;

procedure TCEFWindowParent.UpdateSize;
var
  TempRect : TRect;
  hdwp: THandle;
  TempHandle : THandle;
begin
  TempHandle := ChildWindowHandle;
  if (TempHandle = 0) then Exit;

  TempRect := GetClientRect;
  hdwp     := BeginDeferWindowPos(1);

  try
    hdwp := DeferWindowPos(hdwp, TempHandle, 0,
                           TempRect.left, TempRect.top, TempRect.right - TempRect.left, TempRect.bottom - TempRect.top,
                           SWP_NOZORDER);
  finally
    EndDeferWindowPos(hdwp);
  end;
end;

procedure TCEFWindowParent.WndProc(var aMessage: TMessage);
var
  TempHandle : THandle;
begin
  case aMessage.Msg of
    WM_SETFOCUS:
      begin
        TempHandle := ChildWindowHandle;
        if (TempHandle <> 0) then PostMessage(TempHandle, WM_SETFOCUS, aMessage.WParam, 0);
        inherited WndProc(aMessage);
      end;

    WM_ERASEBKGND:
      begin
        TempHandle := ChildWindowHandle;
        if (csDesigning in ComponentState) or (TempHandle = 0) then inherited WndProc(aMessage);
      end;

    CM_WANTSPECIALKEY:
      if not(TWMKey(aMessage).CharCode in [VK_LEFT .. VK_DOWN, VK_RETURN, VK_ESCAPE]) then
        aMessage.Result := 1
       else
        inherited WndProc(aMessage);

    WM_GETDLGCODE : aMessage.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;

    else inherited WndProc(aMessage);
  end;
end;

end.
