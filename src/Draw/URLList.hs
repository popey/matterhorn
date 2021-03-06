module Draw.URLList
  ( renderUrlList
  )
where

import           Prelude ()
import           Prelude.MH

import           Brick
import           Brick.Widgets.List ( renderList )
import qualified Data.Foldable as F
import           Lens.Micro.Platform ( to )

import           Network.Mattermost.Types ( ServerTime(..) )

import           Draw.Messages
import           Draw.Util
import           Draw.RichText
import           Themes
import           Types
import           Types.RichText ( unURL )


renderUrlList :: ChatState -> Widget Name
renderUrlList st =
    header <=> urlDisplay
    where
        header = withDefAttr channelHeaderAttr $ vLimit 1 $
                 (txt $ "URLs: " <> (st^.csCurrentChannel.ccInfo.cdName)) <+>
                 fill ' '

        urlDisplay = if F.length urls == 0
                     then str "No URLs found in this channel."
                     else renderList renderItem True urls

        urls = st^.csUrlList

        me = myUsername st

        renderItem sel link =
          let time = link^.linkTime
          in attr sel $ vLimit 2 $
            (vLimit 1 $
             hBox [ let u = maybe "<server>" id (link^.linkUser.to (nameForUserRef st))
                    in colorUsername me u u
                  , case link^.linkLabel of
                      Nothing -> emptyWidget
                      Just label -> txt ": " <+> hBox (F.toList $ renderElementSeq me label)
                  , fill ' '
                  , renderDate st $ withServerTime time
                  , str " "
                  , renderTime st $ withServerTime time
                  ] ) <=>
            (vLimit 1 (renderText $ unURL $ link^.linkURL))

        attr True = forceAttr urlListSelectedAttr
        attr False = id
