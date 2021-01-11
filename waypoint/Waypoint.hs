{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# OPTIONS_GHC -Wno-partial-type-signatures #-}
{-# OPTIONS_GHC -ddump-core-stats #-}

module Waypoint where

import Mu.GRpc.Server (msgProtoBuf, runGRpcApp)
import Mu.Quasi.GRpc (grpc)
import Mu.Schema (Term, (:/:))
import Mu.Server (HandlersT (H0, (:<|>:)), MonadServer, SingleServerT, method, singleService)
import qualified Mu.Server as Mu

grpc "WP" id "waypoint.proto"

type X a = Term WP (WP :/: a)

buildServer :: MonadServer m => SingleServerT info Builder m _
buildServer =
  Mu.Server
    ( -- pure @_ @(X "ImplementsResp") undefined
      --   :<|>: (\(_ :: X "FuncSpec.Args") -> pure @_ @(X "Auth.AuthResponse") undefined)
      --   :<|>: pure @_ @(X "FuncSpec") undefined
      --   :<|>: (\(_ :: X "FuncSpec.Args") -> pure @_ @() undefined)
      --   :<|>: pure @_ @(X "FuncSpec") undefined
      -- :<|>:
      pure @_ @(X "Config.StructResp") undefined
        :<|>: (\(_ :: X "Config.ConfigureRequest") -> pure @_ @() undefined)
        :<|>: pure @_ @(X "Config.Documentation") undefined
        :<|>: pure @_ @(X "FuncSpec") undefined
        :<|>: (\(_ :: X "FuncSpec.Args") -> pure @_ @(X "Build.Resp") undefined)
        :<|>: H0
    )

serveBuild :: IO ()
serveBuild = runGRpcApp msgProtoBuf 9191 buildServer
