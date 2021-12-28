{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_bancodesangue (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "C:\\Users\\Matheus\\Documents\\FATEC\\projetos_haskell\\yesod\\Banco-de-Sangue\\yesodvazio\\.stack-work\\install\\5af6e31e\\bin"
libdir     = "C:\\Users\\Matheus\\Documents\\FATEC\\projetos_haskell\\yesod\\Banco-de-Sangue\\yesodvazio\\.stack-work\\install\\5af6e31e\\lib\\x86_64-windows-ghc-8.10.4\\bancodesangue-1.0.0-KZBW3Vczhg349CuMWG7sqt-bancodesangue"
dynlibdir  = "C:\\Users\\Matheus\\Documents\\FATEC\\projetos_haskell\\yesod\\Banco-de-Sangue\\yesodvazio\\.stack-work\\install\\5af6e31e\\lib\\x86_64-windows-ghc-8.10.4"
datadir    = "C:\\Users\\Matheus\\Documents\\FATEC\\projetos_haskell\\yesod\\Banco-de-Sangue\\yesodvazio\\.stack-work\\install\\5af6e31e\\share\\x86_64-windows-ghc-8.10.4\\bancodesangue-1.0.0"
libexecdir = "C:\\Users\\Matheus\\Documents\\FATEC\\projetos_haskell\\yesod\\Banco-de-Sangue\\yesodvazio\\.stack-work\\install\\5af6e31e\\libexec\\x86_64-windows-ghc-8.10.4\\bancodesangue-1.0.0"
sysconfdir = "C:\\Users\\Matheus\\Documents\\FATEC\\projetos_haskell\\yesod\\Banco-de-Sangue\\yesodvazio\\.stack-work\\install\\5af6e31e\\etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "bancodesangue_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "bancodesangue_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "bancodesangue_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "bancodesangue_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "bancodesangue_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "bancodesangue_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "\\" ++ name)
