-- Base
import XMonad
import System.Exit ()
import qualified XMonad.StackSet as W

-- Data
import Data.Monoid ()
import qualified Data.Map        as M
import Data.Maybe (maybeToList)

-- Hooks
import XMonad.Hooks.EwmhDesktops ( ewmh )
import XMonad.Hooks.ManageDocks
    ( avoidStruts, docks, docksEventHook, manageDocks, ToggleStruts(..) )
import XMonad.Hooks.ManageHelpers ( doFullFloat, isFullscreen )

-- Layouts
import XMonad.Layout.SimplestFloat

-- Layout Modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Fullscreen
    ( fullscreenEventHook, fullscreenManageHook, fullscreenSupport, fullscreenFull )
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing ( spacingRaw, Border(Border) )
import XMonad.Layout.SubLayouts
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Spacing
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))


-- Utils
import XMonad.Util.SpawnOnce ( spawnOnce )
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (spawnPipe)

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["\63083", "\63288", "\63306", "\61723", "\63107", "\63601", "\63391", "\61713", "\61884"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#3b4252"
myFocusedBorderColor = "#bc96da"


------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
clipboardy :: MonadIO m => m () -- Don't question it 
clipboardy = spawn "rofi -modi \"\63053 :greenclip print\" -show \"\63053 \" -run-command '{cmd}' -theme ~/.config/rofi/launcher/style.rasi"

centerlaunch = spawn "exec ~/bin/eww open-many blur_full weather profile quote search_full incognito-icon vpn-icon home_dir screenshot power_full reboot_full lock_full logout_full suspend_full"
sidebarlaunch = spawn "exec ~/bin/eww open-many weather_side time_side smol_calendar player_side sys_side sliders_side"
ewwclose = spawn "exec ~/bin/eww close-all"
maimcopy = spawn "maim -s | xclip -selection clipboard -t image/png && notify-send \"Screenshot\" \"Copied to Clipboard\" -i flameshot"
maimsave = spawn "maim -s ~/Desktop/$(date +%Y-%m-%d_%H-%M-%S).png && notify-send \"Screenshot\" \"Saved to Desktop\" -i flameshot"
rofi_launcher = spawn "rofi -no-lazy-grab -show drun -modi run,drun,window -theme $HOME/.config/rofi/launcher/style -drun-icon-theme \"candy-icons\" "
myTerminal = "alacritty"    -- Sets default terminal



-- START_KEYS
myKeys :: [(String, X ())]
myKeys =
    --KB_GROUP Xmonad
        [ ("M-S-q", spawn "~/bin/powermenu.sh")                                 -- Quit Xmonad
        , ("M-q", spawn "xmonad --recompile; xmonad --restart")                 -- Recompile and Restart Xmonad
   
    --KB_GROUP Rofi
        , ("M-o", rofi_launcher)                                                -- Rofi

    --KB_GROUP Dashboards
        , ("M-p", centerlaunch)                                                 -- Center Dashboard
        , ("M-S-p", ewwclose)                                                   -- Close Dashboards
        , ("M-s", sidebarlaunch)                                                -- Side Dashboard
        , ("M-S-s", ewwclose)                                                   -- Close Dashboards

    -- KB_GROUP Useful programs to have a keybinding for launch
        , ("M-S-<Return>", spawn (myTerminal))                                  -- Launch a Terminal
    
    -- KB_GROUP Floating windows
        , ("M-t", withFocused $ windows . W.sink)                               -- Push window back into tiling

    -- KB_Group Kill windows
        , ("M-S-c", kill)                                                       -- Kill Focused Window

    -- KB_GROUP Desktop behavior
        , ("M-<F1>", spawn "betterlockscreen -l")                               -- Lock the Screen
        , ("M-S-3", maimcopy)                                                   -- Put Screenshot into Clipboard
        , ("M-S-4", maimsave)                                                   -- Save Screenshot to ~/Desktop
        , ("M-S-a", clipboardy)                                                 -- Open Clipboard
        , ("M-z", spawn "exec ~/bin/inhibit_activate")                          -- Deactivate Lockscreen
        , ("M-S-z", spawn "exec ~/bin/inhibit_deactivate")                      -- Activate Lockscreen

    -- KB_GROUP Layouts
        , ("M-b", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)   -- Toggles noborder/full
        , ("M-<Space>", sendMessage NextLayout)                                 -- Switch to next layout
        , ("M-n", refresh)                                                      -- Resize viewed windows to the correct size

    -- KB_GROUP Increase/decrease windows in the master pane or the stack
        , ("M-,", sendMessage (IncMasterN 1))                                   -- Increment the number of windows in the master area
        , ("M-.", sendMessage (IncMasterN (-1)))                                -- Deincrement the number of windows in the master area

    -- KB_GROUP Window Resizing
        , ("M-h", sendMessage Shrink)                                           -- Shrink the master area
        , ("M-l", sendMessage Expand)                                           -- Expand the master area

    -- KB_GROUP Multimedia Keys
        , ("<XF86AudioPlay>", spawn "playerctl play-pause")
        , ("<XF86AudioPrev>", spawn "playerctl previous")
        , ("<XF86AudioNext>", spawn "playerctl next")
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+")
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%-")
        , ("<XF86AudioMute>", spawn "amixer set Master toggle")
        , ("<XF86KbdBrightnessUp>", spawn "brightnessctl -d smc::kbd_backlight s +10%")
        , ("<XF86KbdBrightnessDown>", spawn "brightnessctl -d smc::kbd_backlight s 10-%")
        , ("<XF86MonBrightnessUp>", spawn "brightnessctl s +10%")
        , ("<XF86MonBrightnessDown>", spawn "brightnessctl s 10-%")

    -- KB_GROUP Windows navigation
        , ("M-<Tab>", windows W.focusDown)                                      -- Move focus to the next window
        , ("M-j", windows W.focusDown)                                          -- Move focus to the next window
        , ("M-k", windows W.focusUp)                                            -- Move focus to the previous window
        , ("M-m", windows W.focusMaster)                                        -- Move focus to the master window
        , ("M-<Return>", windows W.swapMaster)                                  -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)                                         -- Swap the focused window with the next window
        , ("M-S-k", windows W.swapUp)                                           -- Swap the focused window with the previous window
        ]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border (30+i) i i i) True (Border i i i i) True
--
---- Below is a variation of the above except no borders are applied
---- if fewer than two windows. So a single window has no gaps.
--mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
--mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

tall     = renamed [Replace "tall"]
           $ smartBorders
           $ windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing 8
           $ Tall 1 (3/100) (1/2)

mirror   = renamed [Replace "mirror"]
           $ smartBorders
           $ windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing 8
           $ Mirror (Tall 1 (3/100) (1/2))

monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ Full

myLayout = avoidStruts $ smartBorders $ windowArrange $ T.toggleLayouts simplestFloat
            $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
    where 
        myDefaultLayout = withBorder myBorderWidth tall ||| mirror ||| monocle

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = fullscreenManageHook <+> manageDocks <+> composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , isFullscreen --> doFullFloat
                                 ]

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawnOnce "exec ~/bin/eww daemon"
  spawn "xsetroot -cursor_name left_ptr"
  spawn "exec ~/bin/lock.sh"
  spawnOnce "nitrogen --restore"
  spawnOnce "picom --experimental-backends"
  spawnOnce "greenclip daemon"
  spawnOnce "dunst"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    xmproc0 <- spawnPipe "tint2 -c ~/.config/tint2/clock.tint2rc"
    xmproc1 <- spawnPipe "tint2 -c ~/.config/tint2/customscripts.tint2rc"
    xmproc2 <- spawnPipe "tint2 -c ~/.config/tint2/workspaces.tint2rc"

    xmonad $ fullscreenSupport $ docks $ ewmh defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal            = myTerminal,
        focusFollowsMouse   = myFocusFollowsMouse,
        clickJustFocuses    = myClickJustFocuses,
        borderWidth         = myBorderWidth,
        modMask             = myModMask,
        workspaces          = myWorkspaces,
        normalBorderColor   = myNormalBorderColor,
        focusedBorderColor  = myFocusedBorderColor,

      -- key bindings
        mouseBindings       = myMouseBindings,

      -- hooks, layouts
        manageHook          = myManageHook <+> manageDocks,
        handleEventHook     = docksEventHook, 
        layoutHook          = myLayout,
        logHook             = myLogHook,
        startupHook         = myStartupHook
    } `additionalKeysP` myKeys
