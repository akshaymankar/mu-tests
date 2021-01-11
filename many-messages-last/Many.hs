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

module Many where

import Mu.GRpc.Server (msgProtoBuf, runGRpcApp)
import Mu.Quasi.GRpc (grpc)
import Mu.Schema (Term, (:/:))
import Mu.Server (HandlersT (H0, (:<|>:)), MonadServer, SingleServerT, method, singleService)
import qualified Mu.Server as Mu

grpc "Many" id "many.proto"

type X a = Term Many (Many :/: a)

server :: MonadServer m => SingleServerT info Service100 m _
server =
  Mu.Server
    (pure @_ @(X "Foo100") :<|>: H0)

serve :: IO ()
serve = runGRpcApp msgProtoBuf 9191 server
