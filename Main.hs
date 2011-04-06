{-# LANGUAGE TypeFamilies, QuasiQuotes, MultiParamTypeClasses, TemplateHaskell #-}
import Yesod

import Control.Monad
import System.Cmd
import System.Exit

repourl = "git@github.com:tanakh/tanakh.jp.git"
wwwdir = "/var/www/nginx-default"

data GithubHook = GithubHook

mkYesod "GithubHook" [parseRoutes|
/ HomeR GET
|]

instance Yesod GithubHook where
    approot _ = ""

getHomeR = do
  liftIO $ updateSite
  defaultLayout [hamlet|ok.|]

main = warpDebug 3001 GithubHook

--

system' cmd = do
  r <- system cmd
  when (r /= ExitSuccess) $ do
    error $ "command " ++ cmd ++ "failed"

updateSite = do
  system' $ "rm -rf site"
  system' $ "git clone " ++ repourl ++ " site"
  system' $ "cp -rf site " ++ wwwdir
  system' $ "rm -rf site"
