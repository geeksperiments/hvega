{-# LANGUAGE OverloadedStrings #-}

{-|
Module      : Graphics.Vega.VegaLite.Foundation
Copyright   : (c) Douglas Burke, 2018-2019
License     : BSD3

Maintainer  : dburke.gw@gmail.com
Stability   : unstable
Portability : OverloadedStrings

Basic types that are used throughout VegaLite.

-}

module Graphics.Vega.VegaLite.Foundation
       ( Angle
       , Color
       , Opacity
       , ZIndex

       , FontWeight(..)
       , Measurement(..)
       , Arrangement(..)
       , APosition(..)
       , Orientation(..)
       , Position(..)

       , HAlign(..)
       , VAlign(..)

       , StrokeCap(..)
       , StrokeJoin(..)

       , Scale(..)

       , SortField(..)

       , Cursor(..)

       , OverlapStrategy(..)
       , Side(..)

       , Symbol(..)

       , StackProperty(..)
       , StackOffset(..)

       , TooltipContent(..)

       -- not for external export
       , fontWeightSpec
       , measurementLabel
       , arrangementLabel
       , anchorLabel
       , orientationSpec
       , hAlignLabel
       , vAlignLabel
       , strokeCapLabel
       , strokeJoinLabel
       , scaleLabel
       , positionLabel
       , sortFieldSpec
       , cursorLabel
       , overlapStrategyLabel
       , sideLabel
       , symbolLabel
       , stackPropertySpecSort
       , stackPropertySpecOffset
       , stackOffset
       , ttContentLabel

       , field_
       , order_
       )
    where

import qualified Data.Aeson as A
import qualified Data.Text as T

import Data.Aeson ((.=), object, toJSON)


-- added in base 4.8.0.0 / ghc 7.10.1
import Numeric.Natural (Natural)


import Graphics.Vega.VegaLite.Specification (VLSpec, LabelledSpec)


field_ :: T.Text -> LabelledSpec
field_ f = "field" .= f

-- could restrict to ascending/descending
order_ :: T.Text -> LabelledSpec
order_ o = "order" .= o


{-|

Convenience type-annotation label to indicate a color value.
There is __no attempt__ to validate that the user-supplied input
is a valid color.

Any supported HTML color specification can be used, such as:

@
\"#eee\"
\"#734FD8\"
\"crimson\"
\"rgb(255,204,210)\"
\"hsl(180, 50%, 50%)\"
@

@since 0.4.0.0
-}

type Color = T.Text


{-|

Convenience type-annotation label to indicate an opacity value, which
lies in the range 0 to 1 inclusive. There is __no attempt__ to validate
that the user-supplied value falls in this range.

A value of 0 indicates fully transparent (see through), and 1 is
fully opaque (does not show anything it is on top of).

@since 0.4.0.0
-}

type Opacity = Double


{-|

Convenience type-annotation label to indicate an angle, which is measured
in degrees from the horizontal (so anti-clockwise).

The value should be in the range 0 to 360, inclusive, but __no attempt__ is
made to enforce this.

@since 0.4.0.0
-}

type Angle = Double


{-|

At what "depth" (z index) is the item to be drawn (a relative depth
for items in the visualization). The standard values are @0@ for
back and @1@ for front, but other values can be used if you want
to ensure a certain layering of items.

The following example is taken from a discussion with
<https://github.com/gicentre/elm-vegalite/issues/15#issuecomment-524527125 Jo Wood>:

@
let dcols = 'Graphics.Vega.VegaLite.dataFromColumns' []
              . 'Graphics.Vega.VegaLite.dataColumn' "x" ('Graphics.Vega.VegaLite.Numbers' [ 20, 10 ])
              . 'Graphics.Vega.VegaLite.dataColumn' "y" ('Graphics.Vega.VegaLite.Numbers' [ 10, 20 ])
              . 'Graphics.Vega.VegaLite.dataColumn' "cat" ('Graphics.Vega.VegaLite.Strings' [ "a", "b" ])

    axis lbl z = [ 'Graphics.Vega.VegaLite.PName' lbl, 'Graphics.Vega.VegaLite.PmType' 'Graphics.Vega.VegaLite.Quantitative', 'Graphics.Vega.VegaLite.PAxis' [ 'Graphics.Vega.VegaLite.AxZIndex' z ] ]
    enc = 'Graphics.Vega.VegaLite.encoding'
            . 'Graphics.Vega.VegaLite.position' 'X' (axis "x" 2)
            . 'Graphics.Vega.VegaLite.position' 'Y' (axis "y" 1)
            . 'Graphics.Vega.VegaLite.color' [ 'Graphics.Vega.VegaLite.MName' "cat", 'Graphics.Vega.VegaLite.MmType' 'Graphics.Vega.VegaLite.Nominal', 'Graphics.Vega.VegaLite.MLegend' [] ]

    cfg = 'Graphics.Vega.VegaLite.configure'
            . 'Graphics.Vega.VegaLite.configuration' ('Graphics.Vega.VegaLite.Axis' [ 'Graphics.Vega.VegaLite.GridWidth' 8 ])
            . 'Graphics.Vega.VegaLite.configuration' ('Graphics.Vega.VegaLite.AxisX' [ 'Graphics.Vega.VegaLite.GridColor' "red" ])
            . 'Graphics.Vega.VegaLite.configuration' ('Graphics.Vega.VegaLite.AxisY' [ 'Graphics.Vega.VegaLite.GridColor' "blue" ])

in 'Graphics.Vega.VegaLite.toVegaLite' [ cfg []
              , dcols []
              , enc []
              , 'Graphics.Vega.VegaLite.mark' 'Graphics.Vega.VegaLite.Circle' [ 'Graphics.Vega.VegaLite.MSize' 5000, 'Graphics.Vega.VegaLite.MOpacity' 1 ]
              ]
@

<<images/zindex.png>>

<https://vega.github.io/editor/#/url/vega-lite/N4KABBYEQMYPYDsBmBLA5lAXGUk-QEMAPFAZwE0sdx9ao0AnFAEwGE4AbOBqqAIw4BXAKZQatAL4AacfijEyADSq5acxi3Zce2KA2HMxasNNl55JUirNr6TZgHUWAFwAWVABw2IE2afMAtgQMANbWxlCkKABeotgArAAMyTIRcAAOBDAozgCeVACMqbZ56XHQ2QwwHKJ+xRBQzATOBOG2AG4EQsJW2ADa3viqxnQwzbyt9SPmRFQATIlT0w352AWJg3j+y8PLDWPOvHxQS8tQs2uLm7arYAvXPoMAunWyUAAkpDCuwkG8rs5nOlSJgAPSg9rCNAEAB0aByrkEfBhKDgoK+PyCEKhBAAtBwcsIIQBmGEAK1IiBOb2ECHgzBQCAw2F25ng2ja0ygqGEHEMugO1L2UFK5SgCDgAUZXSFZxqaFp-LACEEHA4g22dAu1GFPL5vFmpzoot4AEdBAQEM4cs0UJDZVyFL0dXtIFBoozmMJtXMHiYNUboLdWbY9UqoPlA+YTbpzZbrS1rfao26nZzXe7Pd7Cn7fMY85BfL4gA View the visualization in the Vega Editor>

@since 0.4.0.0
-}

type ZIndex = Natural


-- | Indicates the weight options for a font.

data FontWeight
    = Bold
    | Bolder
    | Lighter
    | Normal
    | W100
    | W200
    | W300
    | W400
    | W500
    | W600
    | W700
    | W800
    | W900


fromF :: Double -> VLSpec
fromF = toJSON

fromT :: T.Text -> VLSpec
fromT = toJSON


fontWeightSpec :: FontWeight -> VLSpec
fontWeightSpec Bold = fromT "bold"
fontWeightSpec Bolder = fromT "bolder"
fontWeightSpec Lighter = fromT "lighter"
fontWeightSpec Normal = fromT "normal"
fontWeightSpec W100 = fromF 100
fontWeightSpec W200 = fromF 200
fontWeightSpec W300 = fromF 300
fontWeightSpec W400 = fromF 400
fontWeightSpec W500 = fromF 500
fontWeightSpec W600 = fromF 600
fontWeightSpec W700 = fromF 700
fontWeightSpec W800 = fromF 800
fontWeightSpec W900 = fromF 900


{-|

Type of measurement to be associated with some channel.

-}

data Measurement
    = Nominal
      -- ^ Data are categories identified by name alone and which have no intrinsic order.
    | Ordinal
      -- ^ Data are also categories, but ones which have some natural order.
    | Quantitative
      -- ^ Data are numeric measurements typically on a continuous scale.
    | Temporal
      -- ^ Data represents time in some manner.
    | GeoFeature
      -- ^ Geospatial position encoding ('Longitude' and 'Latitude') should specify the 'Graphics.Vega.VegaLite.PmType'
      -- as @Quantitative@. Geographically referenced features encoded as 'Graphics.Vega.VegaLite.shape' marks
      -- should specify 'Graphics.Vega.VegaLite.MmType' as @GeoFeature@ (Vega-Lite currently refers to this type
      -- as @<https://vega.github.io/vega-lite/docs/encoding.html geojson>@.


measurementLabel :: Measurement -> T.Text
measurementLabel Nominal = "nominal"
measurementLabel Ordinal = "ordinal"
measurementLabel Quantitative = "quantitative"
measurementLabel Temporal = "temporal"
measurementLabel GeoFeature = "geojson"


-- | Identifies how repeated or faceted views are arranged.
--
--   This is used with a number of constructors: 'Graphics.Vega.VegaLite.ByRepeatOp',
--   'Graphics.Vega.VegaLite.HRepeat', 'Graphics.Vega.VegaLite.MRepeat', 'Graphics.Vega.VegaLite.ORepeat', 'Graphics.Vega.VegaLite.PRepeat', and 'Graphics.Vega.VegaLite.TRepeat'.

-- based on schema 3.3.0 #/definitions/RepeatRef

data Arrangement
    = Column
      -- ^ Column arrangement.
    | Row
      -- ^ Row arrangement.
    | Flow
      -- ^ Flow arrangement (aka \"repeat\").
      --
      --   @since 0.4.0.0


arrangementLabel :: Arrangement -> T.Text
arrangementLabel Column = "column"
arrangementLabel Row = "row"
arrangementLabel Flow = "repeat"  -- NOTE: not "flow"!


-- | Indicates the anchor position for text.

data APosition
    = AStart
      -- ^ The start of the text.
    | AMiddle
      -- ^ The middle of the text.
    | AEnd
      -- ^ The end of the text.


anchorLabel :: APosition -> T.Text
anchorLabel AStart = "start"
anchorLabel AMiddle = "middle"
anchorLabel AEnd = "end"


{-|

The orientation of an item. This is used with:
'Graphics.Vega.VegaLite.BLeLDirection', 'Graphics.Vega.VegaLite.LDirection',
'Graphics.Vega.VegaLite.LeGradientDirection', 'Graphics.Vega.VegaLite.LeLDirection', 'Graphics.Vega.VegaLite.LeSymbolDirection',
and 'Graphics.Vega.VegaLite.MOrient'.

In @0.4.0.0@ this was renamed from @MarkOrientation@ to 'Orientation'.

-}

-- based on schema 3.3.0 #/definitions/Orientation

data Orientation
    = Horizontal
      -- ^ Display horizontally.
    | Vertical
      -- ^ Display vertically.


orientationSpec :: Orientation -> VLSpec
orientationSpec Horizontal = "horizontal"
orientationSpec Vertical = "vertical"


-- TODO:
--
--  encoding of X2/... shouldn't include the PmType in the output, apparently
--  so we could try and filter that out, or just rely on the user to not
--  add the PmType fields in this case.

{-|

Type of position channel, @X@ and @Y@ represent horizontal and vertical axis
dimensions on a plane and @X2@ and @Y2@ represent secondary axis dimensions where
two scales are overlaid in the same space. Geographic positions represented by
longitude and latiutude values are identified with @Longitude@, @Latitude@ and
their respective secondary equivalents. Such geographic position channels are
subject to a map projection (set using 'Graphics.Vega.VegaLite.projection') before being placed graphically.

-}
data Position
    = X
    | Y
    | X2
    -- ^ The secondary coordinate for ranged 'Graphics.Vega.VegaLite.Area', 'Graphics.Vega.VegaLite.Bar', 'Graphics.Vega.VegaLite.Rect', and 'Graphics.Vega.VegaLite.Rule'
    --    marks.
    | Y2
    -- ^ The secondary coordinate for ranged 'Graphics.Vega.VegaLite.Area', 'Graphics.Vega.VegaLite.Bar', 'Graphics.Vega.VegaLite.Rect', and 'Graphics.Vega.VegaLite.Rule'
    --    marks.
    | XError
      -- ^ Indicates that the 'X' channel represents the mid-point and
      --   the 'XError' channel gives the offset. If 'XError2' is not
      --   defined then this channel value is applied symmetrically.
      --
      --   @since 0.4.0.0
    | XError2
      -- ^ Used to support asymmetric error ranges defined as 'XError'
      --   and 'XError2'. One of 'XError' or 'XError2' channels must
      --   contain positive values and the other negative values.
      --
      --   @since 0.4.0.0
    | YError
      -- ^ Indicates that the 'Y' channel represents the mid-point and
      --   the 'YError' channel gives the offset. If 'YError2' is not
      --   defined then this channel value is applied symmetrically.
      --
      --   @since 0.4.0.0
    | YError2
      -- ^ Used to support asymmetric error ranges defined as 'YError'
      --   and 'YError2'. One of 'YError' or 'YError2' channels must
      --   contain positive values and the other negative values.
      --
      --   @since 0.4.0.0
    | Longitude
      -- ^ The longitude value for projections.
    | Latitude
      -- ^ The latitude value for projections.
    | Longitude2
      -- ^ A second longitude coordinate.
    | Latitude2
      -- ^ A second longitude coordinate.


positionLabel :: Position -> T.Text
positionLabel X = "x"
positionLabel Y = "y"
positionLabel X2 = "x2"
positionLabel Y2 = "y2"
positionLabel XError     = "xError"
positionLabel YError     = "yError"
positionLabel XError2    = "xError2"
positionLabel YError2    = "yError2"
positionLabel Longitude = "longitude"
positionLabel Latitude = "latitude"
positionLabel Longitude2 = "longitude2"
positionLabel Latitude2 = "latitude2"



-- | Indicates the horizontal alignment of text such as on an axis or legend.

data HAlign
    = AlignCenter
    | AlignLeft
    | AlignRight


-- | Indicates the vertical alignment of text that may be attached to a mark.

data VAlign
    = AlignTop
    | AlignMiddle
    | AlignBottom


hAlignLabel :: HAlign -> T.Text
hAlignLabel AlignLeft = "left"
hAlignLabel AlignCenter = "center"
hAlignLabel AlignRight = "right"


vAlignLabel :: VAlign -> T.Text
vAlignLabel AlignTop = "top"
vAlignLabel AlignMiddle = "middle"
vAlignLabel AlignBottom = "bottom"


-- | How are strokes capped? This is used with 'Graphics.Vega.VegaLite.MStrokeCap', 'Graphics.Vega.VegaLite.VBStrokeCap',
--   and 'Graphics.Vega.VegaLite.ViewStrokeCap'.
--
--   @since 0.4.0.0

data StrokeCap
    = CButt
      -- ^ Butt stroke cap.
    | CRound
      -- ^ Rounded stroke cap.
    | CSquare
      -- ^ Square stroke cap.


strokeCapLabel :: StrokeCap -> T.Text
strokeCapLabel CButt = "butt"
strokeCapLabel CRound = "round"
strokeCapLabel CSquare = "square"


-- | How are strokes joined? This is used with 'Graphics.Vega.VegaLite.MStrokeJoin', 'Graphics.Vega.VegaLite.VBStrokeJoin',
--   and 'Graphics.Vega.VegaLite.ViewStrokeJoin'.
--
--
--   @since 0.4.0.0

data StrokeJoin
    = JMiter
      -- ^ Mitred stroke join.
    | JRound
      -- ^ Rounded stroke join.
    | JBevel
      -- ^ Bevelled stroke join.


strokeJoinLabel :: StrokeJoin -> T.Text
strokeJoinLabel JMiter = "miter"
strokeJoinLabel JRound = "round"
strokeJoinLabel JBevel = "bevel"


-- | Used to indicate the type of scale transformation to apply.
--
--   The @0.4.0.0@ release removed the @ScSequential@ constructor, as
--   'ScLinear' should be used instead.

data Scale
    = ScLinear
      -- ^ A linear scale.
    | ScPow
      -- ^ A power scale. The exponent to use for scaling is specified with
      --   'Graphics.Vega.VegaLite.SExponent'.
    | ScSqrt
      -- ^ A square-root scale.
    | ScLog
      -- ^ A log scale. Defaults to log of base 10, but can be customised with
      --   'Graphics.Vega.VegaLite.SBase'.
    | ScSymLog
      -- ^ A [symmetrical log (PDF link)](https://www.researchgate.net/profile/John_Webber4/publication/233967063_A_bi-symmetric_log_transformation_for_wide-range_data/links/0fcfd50d791c85082e000000.pdf)
      --   scale. Similar to a log scale but supports zero and negative values. The slope
      --   of the function at zero can be set with 'Graphics.Vega.VegaLite.SConstant'.
      --
      --   @since 0.4.0.0
    | ScTime
      -- ^ A temporal scale.
    | ScUtc
      -- ^ A temporal scale, in UTC.
    | ScOrdinal
      -- ^ An ordinal scale.
    | ScBand
      -- ^ A band scale.
    | ScPoint
      -- ^ A point scale.
    | ScBinLinear
      -- ^ A linear band scale.
    | ScBinOrdinal
      -- ^ An ordinal band scale.
    | ScQuantile
      -- ^ A quantile scale.
      --
      --   @since 0.4.0.0
    | ScQuantize
      -- ^ A quantizing scale.
      --
      --   @since 0.4.0.0
    | ScThreshold
      -- ^ A threshold scale.
      --
      --   @since 0.4.0.0


scaleLabel :: Scale -> T.Text
scaleLabel ScLinear = "linear"
scaleLabel ScPow = "pow"
scaleLabel ScSqrt = "sqrt"
scaleLabel ScLog = "log"
scaleLabel ScSymLog = "symlog"
scaleLabel ScTime = "time"
scaleLabel ScUtc = "utc"
scaleLabel ScOrdinal = "ordinal"
scaleLabel ScBand = "band"
scaleLabel ScPoint = "point"
scaleLabel ScBinLinear = "bin-linear"
scaleLabel ScBinOrdinal = "bin-ordinal"
scaleLabel ScQuantile = "quantile"
scaleLabel ScQuantize = "quantize"
scaleLabel ScThreshold = "threshold"


-- | How should the field be sorted when performing a window transform.
--
--   @since 0.4.00

data SortField
    = WAscending T.Text
    -- ^ Sort the field into ascending order.
    | WDescending T.Text
    -- ^ Sort the field into descending order.


sortFieldSpec :: SortField -> VLSpec
sortFieldSpec (WAscending f) = object [field_ f, order_ "ascending"]
sortFieldSpec (WDescending f) = object [field_ f, order_ "descending"]


{-|

Represents the type of cursor to display. For an explanation of each type,
see the
<https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#Keyword%20values CSS documentation>.

-}
data Cursor
    = CAuto
    | CDefault
    | CNone
    | CContextMenu
    | CHelp
    | CPointer
    | CProgress
    | CWait
    | CCell
    | CCrosshair
    | CText
    | CVerticalText
    | CAlias
    | CCopy
    | CMove
    | CNoDrop
    | CNotAllowed
    | CAllScroll
    | CColResize
    | CRowResize
    | CNResize
    | CEResize
    | CSResize
    | CWResize
    | CNEResize
    | CNWResize
    | CSEResize
    | CSWResize
    | CEWResize
    | CNSResize
    | CNESWResize
    | CNWSEResize
    | CZoomIn
    | CZoomOut
    | CGrab
    | CGrabbing


cursorLabel :: Cursor -> T.Text
cursorLabel CAuto = "auto"
cursorLabel CDefault = "default"
cursorLabel CNone = "none"
cursorLabel CContextMenu = "context-menu"
cursorLabel CHelp = "help"
cursorLabel CPointer = "pointer"
cursorLabel CProgress = "progress"
cursorLabel CWait = "wait"
cursorLabel CCell = "cell"
cursorLabel CCrosshair = "crosshair"
cursorLabel CText = "text"
cursorLabel CVerticalText = "vertical-text"
cursorLabel CAlias = "alias"
cursorLabel CCopy = "copy"
cursorLabel CMove = "move"
cursorLabel CNoDrop = "no-drop"
cursorLabel CNotAllowed = "not-allowed"
cursorLabel CAllScroll = "all-scroll"
cursorLabel CColResize = "col-resize"
cursorLabel CRowResize = "row-resize"
cursorLabel CNResize = "n-resize"
cursorLabel CEResize = "e-resize"
cursorLabel CSResize = "s-resize"
cursorLabel CWResize = "w-resize"
cursorLabel CNEResize = "ne-resize"
cursorLabel CNWResize = "nw-resize"
cursorLabel CSEResize = "se-resize"
cursorLabel CSWResize = "sw-resize"
cursorLabel CEWResize = "ew-resize"
cursorLabel CNSResize = "ns-resize"
cursorLabel CNESWResize = "nesw-resize"
cursorLabel CNWSEResize = "nwse-resize"
cursorLabel CZoomIn = "zoom-in"
cursorLabel CZoomOut = "zoom-out"
cursorLabel CGrab = "grab"
cursorLabel CGrabbing = "grabbing"


{-|

Type of overlap strategy to be applied when there is not space to show all items
on an axis. See the
<https://vega.github.io/vega-lite/docs/axis.html#labels Vega-Lite documentation>
for more details.
-}

data OverlapStrategy
    = ONone
      -- ^ No overlap strategy to be applied when there is not space to show all items
      --   on an axis.
    | OParity
      -- ^ Give all items equal weight in overlap strategy to be applied when there is
      --   not space to show them all on an axis.
    | OGreedy
      -- ^ Greedy overlap strategy to be applied when there is not space to show all
      --   items on an axis.

overlapStrategyLabel :: OverlapStrategy -> T.Text
overlapStrategyLabel ONone = "false"
overlapStrategyLabel OParity = "parity"
overlapStrategyLabel OGreedy = "greedy"


-- | Represents one side of a rectangular space.

data Side
    = STop
    | SBottom
    | SLeft
    | SRight


sideLabel :: Side -> T.Text
sideLabel STop = "top"
sideLabel SBottom = "bottom"
sideLabel SLeft = "left"
sideLabel SRight = "right"


-- | Identifies the type of symbol used with the 'Graphics.Vega.VegaLite.Point' mark type.
--   It is used with 'Graphics.Vega.VegaLite.MShape', 'Graphics.Vega.VegaLite.LeSymbolType', and 'Graphics.Vega.VegaLite.LSymbolType'.
--
--   In version @0.4.0.0@ all constructors were changed to start
--   with @Sym@.
--
data Symbol
    = SymCircle
      -- ^ Specify a circular symbol for a shape mark.
    | SymSquare
      -- ^ Specify a square symbol for a shape mark.
    | SymCross
      -- ^ Specify a cross symbol for a shape mark.
    | SymDiamond
      -- ^ Specify a diamond symbol for a shape mark.
    | SymTriangleUp
      -- ^ Specify an upward-triangular symbol for a shape mark.
    | SymTriangleDown
      -- ^ Specify a downward-triangular symbol for a shape mark.
    | SymTriangleRight
      -- ^ Specify an right-facing triangular symbol for a shape mark.
      --
      --   @since 0.4.0.0
    | SymTriangleLeft
      -- ^ Specify an left-facing triangular symbol for a shape mark.
      --
      --   @since 0.4.0.0
    | SymStroke
      -- ^ The line symbol.
      --
      --  @since 0.4.0.0
    | SymArrow
      -- ^ Centered directional shape.
      --
      --  @since 0.4.0.0
    | SymTriangle
      -- ^ Centered directional shape. It is not clear what difference
      --   this is to 'SymTriangleUp'.
      --
      --  @since 0.4.0.0
    | SymWedge
      -- ^ Centered directional shape.
      --
      --  @since 0.4.0.0
    | SymPath T.Text
      -- ^ A custom symbol shape as an
      --   [SVG path description](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths).
      --
      --   For correct sizing, the path should be defined within a square
      --   bounding box, defined on an axis of -1 to 1 for both dimensions.


symbolLabel :: Symbol -> T.Text
symbolLabel SymCircle = "circle"
symbolLabel SymSquare = "square"
symbolLabel SymCross = "cross"
symbolLabel SymDiamond = "diamond"
symbolLabel SymTriangleUp = "triangle-up"
symbolLabel SymTriangleDown = "triangle-down"
symbolLabel SymTriangleRight = "triangle-right"
symbolLabel SymTriangleLeft = "triangle-left"
symbolLabel SymStroke = "stroke"
symbolLabel SymArrow = "arrow"
symbolLabel SymTriangle = "triangle"
symbolLabel SymWedge = "wedge"
symbolLabel (SymPath svgPath) = svgPath


-- | How are stacks applied within a transform?
--
--   Prior to version @0.4.0.0@ the @StackProperty@ type was
--   what is now @StackOffset@.

data StackProperty
    = StOffset StackOffset
      -- ^ Stack offset.
      --
      --   @since 0.4.0.0
    | StSort [SortField]
      -- ^ Ordering within a stack.
      --
      --   @since 0.4.0.0


-- | Describes the type of stacking to apply to a bar chart.
--
--   In @0.4.0.0@ this was renamed from @StackProperty@ to @StackOffset@,
--   but the constructor names have not changed.
--
data StackOffset
    = StZero
      -- ^ Offset a stacked layout using a baseline at the foot of
      --   the stack.
    | StNormalize
      -- ^ Rescale a stacked layout to use a common height while
      --   preserving the relative size of stacked quantities.
    | StCenter
      -- ^ Offset a stacked layout using a central stack baseline.
    | NoStack
      -- ^ Do not stack marks, but create a layered plot.

stackOffsetSpec :: StackOffset -> VLSpec
stackOffsetSpec StZero = "zero"
stackOffsetSpec StNormalize = "normalize"
stackOffsetSpec StCenter = "center"
stackOffsetSpec NoStack = A.Null

stackOffset :: StackOffset -> LabelledSpec
stackOffset so = "stack" .= stackOffsetSpec so


stackPropertySpecOffset , stackPropertySpecSort:: StackProperty -> Maybe VLSpec
stackPropertySpecOffset (StOffset op) = Just (stackOffsetSpec op)
stackPropertySpecOffset _ = Nothing

stackPropertySpecSort (StSort sfs) = Just (toJSON (map sortFieldSpec sfs))
stackPropertySpecSort _ = Nothing


-- | This is used with 'Graphics.Vega.VegaLite.MTooltip'.
--
--   @since 0.4.0.0

data TooltipContent
  = TTEncoding
    -- ^ Tooltips are generated by the encoding (this is the default).
    --
    --   For example:
    --
    --   @'Graphics.Vega.VegaLite.mark' 'Graphics.Vega.VegaLite.Circle' ['Graphics.Vega.VegaLite.MTooltip' 'TTEncoding']@
  | TTData
    -- ^ Tooltips are generated by all fields in the underlying data.
    --
    --   For example:
    --
    --   @'Graphics.Vega.VegaLite.mark' 'Graphics.Vega.VegaLite.Circle' ['Graphics.Vega.VegaLite.MTooltip' 'TTData']@
  | TTNone
    -- ^ Disable tooltips.
    --
    --   For example:
    --
    --   @'Graphics.Vega.VegaLite.mark' 'Graphics.Vega.VegaLite.Circle' ['Graphics.Vega.VegaLite.MTooltip' 'TTNone']@


-- Note that TTNone is special cased by markProperty
ttContentLabel :: TooltipContent -> T.Text
ttContentLabel TTEncoding = "encoding"
ttContentLabel TTData = "data"
ttContentLabel TTNone = "null"
