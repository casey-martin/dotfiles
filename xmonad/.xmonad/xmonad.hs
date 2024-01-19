import qualified Data.Map as M

import qualified XMonad.StackSet as W

import Control.Exception
import System.Exit

import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.UpdatePointer
import XMonad.Config.Xfce
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Actions.NoBorders
import XMonad.Hooks.SetWMName
import XMonad.Layout.ComboP
import XMonad.Layout.Grid
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.TwoPane
import XMonad.Actions.CycleSelectedLayouts
import XMonad.Actions.CycleWindows

-- Tabs theme --
myTabTheme = def
    { fontName = "xft:DejaVu Sans Mono:size=10:antialias=true"
    , activeColor         = "#267326"
    , activeBorderColor   = "#40bf40"
    , activeTextColor     = "#ffffff"
    , inactiveColor       = "#496749"
    , inactiveBorderColor = "#333333"
    , inactiveTextColor   = "#dddddd"
    , urgentColor         = "#900000"
    , urgentBorderColor   = "#2f343a"
    , urgentTextColor     = "#ffffff"
    }

-- Main --
main :: IO ()
main = xmonad $ ewmhFullscreen $ conf 

conf = xfceConfig
        { layoutHook        = avoidStruts (myLayoutHook)
        , borderWidth       = 3
        , focusedBorderColor= "darkblue"
        , normalBorderColor = "#444444"
        , workspaces        = map show [1 .. 9 :: Int]
        , modMask           = mod4Mask
        , keys              = myKeys
         }


myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    -- Toggle status bar gap
    [ ((modm,               xK_b     ), sendMessage ToggleStruts)

    -- Log out
    -- , ((modm .|. shiftMask, xK_q     ), spawn "xfce4-session-logout")                  

    -- Change configuration
    , ((modm .|. shiftMask, xK_r     ), spawn "xmonad --recompile; xmonad --restart")

    -- launch a terminal
    , ((modm,               xK_Return), spawn "xfce4-terminal")

    -- launch dmenu
    , ((modm,               xK_d     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")

    -- launch appfinder
    , ((modm .|. shiftMask, xK_p     ), spawn "xfce4-appfinder")

    -- close focused window
    , ((modm .|. shiftMask, xK_q     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)
 
    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
 
    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Bring window to full screen
    , ((modm,               xK_f     ), toggleFull)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)
 
    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)
 
    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )
 
    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )
 
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
 
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
 
    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)
 
    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)
 
    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
 
    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
 
    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)
    
    -- Rotate focused Down
    , ((modm .|. controlMask, xK_j   ), rotFocusedDown)

    -- Rotate focused Up
    , ((modm .|. controlMask, xK_k   ), rotFocusedUp)

    ]
    --
    -- mod-[1..9], Switch to workspace N
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    ++
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
 
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1 or 2
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    -- reordered
    ++
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-- Layouts --
myLayoutHook = tile ||| mtile ||| full ||| tab ||| tabtile 
  where
    rt      = ResizableTall 1 (2/100) (3/5) []
    -- normal vertical tile
    tile    = named "[]="   $ smartBorders rt
    -- normal horizontal tile
    mtile   = named "M[]="  $ smartBorders $ Mirror rt
    -- fullscreen with tabs
    tab     = named "T"     $ noBorders $ tabbed shrinkText myTabTheme
    -- two tab panes beside each other, move windows with SwapWindow
    tabB    = noBorders     $ tabbed shrinkText myTabTheme
    tabtile = named "TT"    $ combineTwoP (TwoPane 0.03 0.5)
                                          (tabB)
                                          (tabB)
                                          (ClassName "firefox")
    -- fullscreen without tabs
    full        = named "[]"    $ noBorders Full

-- Helper --
toggleFull = withFocused (\windowId -> do    
{       
   floats <- gets (W.floating . windowset);        
   if windowId `M.member` floats        
   then do         
       withFocused $ toggleBorder           
       withFocused $ windows . W.sink        
   else do         
       withFocused $ toggleBorder           
       withFocused $  windows . (flip W.float $ W.RationalRect 0 0 1 1)    }    )  
