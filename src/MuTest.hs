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
{-# OPTIONS_GHC -fforce-recomp #-}

-- With big schema, documentation, no maps, no repeated
-- Tidy size (terms,types,coercions) MuTest: 1617 1685799 1978903
module MuTest where

import Language.Haskell.TH.Syntax (addDependentFile)
import Mu.GRpc.Server (msgProtoBuf, runGRpcApp)
import Mu.Quasi.GRpc
import Mu.Schema (Term, (:/:))
import Mu.Server (HandlersT (H0, (:<|>:)), MonadServer, SingleServerT, method, singleService)
import qualified Mu.Server as Mu

-- Findings
-- Nesting too much (> 37) causes -freduction-depth to run out
-- 100 requires -freudction-depth=512

[] <$ addDependentFile "test.proto"

grpc "TestSchema" id "test-waypoint-better.proto"

type Foo = Term TestSchema (TestSchema :/: "Foo")

type Bar = Term TestSchema (TestSchema :/: "Bar")

type X a = Term TestSchema (TestSchema :/: a)

-- getFoo :: MonadServer m => Foo -> m Foo
-- getFoo = pure

server :: MonadServer m => SingleServerT info Service m _
server =
  -- singleService
  --   ( method @"getFoo1" (pure @_ @Foo),
  --     method @"getFoo2" (pure @_ @Foo),
  --     method @"getFoo3" (pure @_ @Foo),
  --     method @"getFoo4" (pure @_ @Foo),
  --     method @"getFoo5" (pure @_ @Foo),
  --     method @"getFoo6" (pure @_ @Foo),
  --     method @"getFoo7" (pure @_ @Foo),
  --     method @"getFoo8" (pure @_ @Foo),
  --     method @"getFoo9" (pure @_ @Foo),
  --     method @"getBar" (pure @_ @Bar)
  --   )
  Mu.Server
    ( (pure @_ @Foo)
        -- :<|>: (pure @_ @Foo)
        -- :<|>: (pure @_ @Foo)
        -- :<|>: (pure @_ @Foo)
        -- :<|>: (pure @_ @Foo)
        -- :<|>: (pure @_ @Foo)
        -- :<|>: (pure @_ @Foo)
        -- :<|>: (pure @_ @Foo)
        -- :<|>: (pure @_ @Foo)
        :<|>: (pure @_ @Bar)
        :<|>: H0
    )

-- isAuthenticator :: MonadServer m => m (X "ImplementsResp")
-- isAuthenticator = undefined

-- buildServer :: MonadServer m => SingleServerT info Builder m _
-- buildServer =
--   Mu.Server
--     ( -- pure @_ @(X "ImplementsResp") undefined
--       --   :<|>: (\(_ :: X "FuncSpec.Args") -> pure @_ @(X "Auth.AuthResponse") undefined)
--       --   :<|>: pure @_ @(X "FuncSpec") undefined
--       --   :<|>: (\(_ :: X "FuncSpec.Args") -> pure @_ @() undefined)
--       --   :<|>: pure @_ @(X "FuncSpec") undefined
--       -- :<|>:
--       -- pure @_ @(X "Config.StructResp") undefined
--       -- :<|>:
--       (\(_ :: X "Config.ConfigureRequest") -> pure @_ @() undefined)
--         :<|>: pure @_ @(X "Config.Documentation") undefined
--         :<|>: pure @_ @(X "FuncSpec") undefined
--         :<|>: (\(_ :: X "FuncSpec.Args") -> pure @_ @(X "Build.Resp") undefined)
--         :<|>: H0
--     )

-- buildServer :: MonadServer m => SingleServerT info Builder m _
-- buildServer = singleService (method @"ConfigStruct" (pure @_ @(X "Config.StructResp") undefined))

serve :: IO ()
serve = runGRpcApp msgProtoBuf 9090 server

-- serveBuild :: IO ()
-- serveBuild = runGRpcApp msgProtoBuf 9191 buildServer
