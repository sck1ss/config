-- IMPORTS
import XMonad
import XMonad.Operations
import XMonad.Actions.CycleWS
import XMonad.Actions.Navigation2D
import Data.List (elemIndex)
import qualified XMonad.StackSet as W
-- HOOKS
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
-- UTILITIES
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
-- NOTE: Importing XMonad.Util.Ungrab is only necessary for versions
-- < 0.18.0! For 0.18.0 and up, this is already included in the
-- XMonad import and will generate a warning instead!
-- LAYOUTS
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.Grid
-- ADDITIONAL HOOKS
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ServerMode


main :: IO ()
main = xmonad
     . ewmhFullscreen
     . ewmh
     . docks
     . withEasySB (statusBarProp "polybar" (pure myPolybarPP)) defToggleStrutsKey
     . navigation2DP def
                              ("<Up>", "<Left>", "<Down>", "<Right>")
                              [("M-",   windowGo  ),
                               ("M-S-", windowSwap)]
                              False
     $ myConfig

myStartupHook :: X ()
myStartupHook = do
         spawn "killall conky"
         spawn "killall polybar"
         spawn "artix-pipewire-loader &"
         spawn "dunst &"
         spawn "picom &"
         spawn "nitrogen --restore"
         spawn "xsetroot -cursor_name left_ptr"
         spawn "conky -c /home/penguin/.config/conky/xmonad.conkyrc"

myConfig = def
    { modMask    = mod4Mask      -- Rebind Mod to the Super key
    , layoutHook = myLayout      -- Use custom layouts
    , manageHook = myManageHook  -- Match on certain windows
    , startupHook = myStartupHook
    , handleEventHook = serverModeEventHookCmd
                        <+> serverModeEventHook
                        <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
    , focusedBorderColor = "#a7f080"
    , borderWidth = 2
    }
  `additionalKeysP`
    [ 
      ("M-p", spawn "dmenu_run")
    , ("M-S-q", spawn "killall xinit" )
    , ("M-q", spawn "killall xmonad-x86_64-linux" )
    , ("M-c", withFocused centerWindow )
    , ("M-t", sendMessage $ JumpToLayout "Tall" )
    , ("M-m", sendMessage $ JumpToLayout "Full" )
    , ("M-d", sendMessage $ JumpToLayout "Spiral" )
    , ("M-g", sendMessage $ JumpToLayout "Grid" )
    , ("M-S-<Return>", spawn "alacritty" )
    , ("M-S-t", withFocused $ windows . W.sink)
    , ("<Print>", spawn "scrot" )
    , ("M-C-<Right>", nextWS )
    , ("M-C-<Left>", prevWS )
    , ("<XF86AudioRaiseVolume>", spawn "pamixer -i 5" )
    , ("<XF86AudioLowerVolume>", spawn "pamixer -d 5" )
    , ("<XF86AudioMute>", spawn "pamixer -t" )
    ]
myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , isDialog            --> doFloat
    , className =? "firefox" --> doShift "9"
    , className =? "vesktop" --> doShift "8"
    , className =? "Gajim" --> doShift "7"
    ]

myLayout = spacingWithEdge 10 $ tiled ||| Full ||| spiral (6/7) ||| Grid
  where
    tiled    = Tall nmaster delta ratio
    nmaster  = 1      -- Default number of windows in the master pane
    ratio    = 1/2    -- Default proportion of screen occupied by master pane
    delta    = 1/100  -- Percent of screen to increment by when resizing panes

myPolybarPP :: PP
myPolybarPP = def
centerWindow :: Window -> X ()
centerWindow win = do
    (_, W.RationalRect x y w h) <- floatLocation win
    windows $ W.float win (W.RationalRect ((1 - w) / 2) ((1 - h) / 2) w h)
    return ()
