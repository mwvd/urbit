::  dice: structures for L2 rollers
::
/+  naive, ethereum
::
|%
+$  owner     [=proxy:naive =address:naive]
+$  owners    (jug owner ship)
+$  sponsors  (map ship [residents=(set ship) requests=(set ship)])
+$  history   (map address:ethereum (tree hist-tx))
+$  net       ?(%mainnet %ropsten %local %default)
::
+$  config
  $%  [%frequency frequency=@dr]
      [%setkey pk=@]
      [%endpoint endpoint=@t =net]
      [%resend-time time=@dr]
      [%update-rate rate=@dr]
      [%slice slice=@dr]
      [%quota quota=@ud]
  ==
::
+$  indices
  $:  own=owners
      spo=sponsors
  ==
::
+$  azimuth-config
  $:  refresh-rate=@dr
  ==
::
+$  roller-config
  $:  next-batch=time
      frequency=@dr
      resend-time=@dr
      update-rate=@dr
      contract=@ux
      chain-id=@
      slice=@dr
      quota=@ud
  ==
::
+$  keccak  @ux
::
+$  status
  ?(%unknown %pending %sending %confirmed %failed %cancelled)
::
+$  tx-status
  $:  =status
      pointer=(unit l1-tx-pointer)
  ==
::
+$  l1-tx-pointer
  $:  =address:ethereum
      nonce=@ud
  ==
::
+$  l2-tx
  $?  %transfer-point
      %spawn
      %configure-keys
      %escape
      %cancel-escape
      %adopt
      %reject
      %detach
      %set-management-proxy
      %set-spawn-proxy
      %set-transfer-proxy
  ==
::
+$  update
  $%  [%tx =pend-tx =status]
    ::
      $:  %point
          =diff:naive
          =ship
          new=point:naive
          old=(unit point:naive)
          to=owner
          from=(unit owner)
  ==  ==
::
+$  hist-tx  [p=time q=roll-tx]
+$  roll-tx  [=ship =status hash=keccak type=l2-tx]
+$  pend-tx  [force=? =address:naive =time =raw-tx:naive]
+$  send-tx  [next-gas-price=@ud sent=? txs=(list raw-tx:naive)]
+$  part-tx
  $%  [%raw raw=octs]
      [%don =tx:naive]
      [%ful raw=octs =tx:naive]  ::TODO  redundant?
  ==
::
+$  rpc-send-roll
  $:  endpoint=@t
      contract=address:ethereum
      chain-id=@
      pk=@
    ::
      nonce=@ud
      next-gas-price=@ud
      txs=(list raw-tx:naive)
  ==
::
+$  roller-data
  [chain-id=@ =points:naive history=(tree hist-tx) =owners =sponsors]
::
+$  command-cli
  $%  ::  List all possible L2 tx types
      ::
      [%l2-tx ~]  :: ?
      ::  Loads a new address (login?)
      ::    — should require signing?
      ::    - it subscribes to the Roller, for updates to it
      ::    - innitially receives a list of points (if any) it controls
      :: TODO: add tag
      ::
      [%connect =ship =address:naive pk=@]
      ::  Table of all submitted txs, by address
      ::
      [%history address:ethereum]
      ::  Table of all unsigned txs, by address
      ::
      [%show-unsigned ~]
      ::  Signs and Submit an unsigned txs (signed)
      ::
      [%submit address:naive tx:naive]
      ::  Cancels a submitted (but pending) txs
      ::
      [%cancel ~]
      ::  Ships owned by an address
      ::
      [%ships address:naive]
      ::  Point data for a given ship
      ::
      [%point ship]
  ==
--
