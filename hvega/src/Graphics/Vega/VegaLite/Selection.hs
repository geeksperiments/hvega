{-# LANGUAGE OverloadedStrings #-}

{-|
Module      : Graphics.Vega.VegaLite.Selection
Copyright   : (c) Douglas Burke, 2018-2020
License     : BSD3

Maintainer  : dburke.gw@gmail.com
Stability   : unstable
Portability : OverloadedStrings

User selections.

-}

module Graphics.Vega.VegaLite.Selection
       ( selection
       , select
       , Selection(..)
       , SelectionProperty(..)
       , Binding(..)
       , BindLegendProperty(..)
       , InputProperty(..)
       , SelectionMarkProperty(..)
       , SelectionResolution(..)

       -- not for external export
       , selectionProperties
       , selectionLabel
       )
    where

import qualified Data.Text as T

import Control.Arrow (second)

import Data.Aeson ((.=), object, toJSON)
import Data.Maybe (mapMaybe)


import Graphics.Vega.VegaLite.Data
  ( DataValue
  , dataValueSpec
  )
import Graphics.Vega.VegaLite.Foundation
  ( Color
  , DashStyle
  , DashOffset
  , FieldName
  , Opacity
  , Channel
  , channelLabel
  , fromT
  , fromColor
  , fromDS
  )
import Graphics.Vega.VegaLite.Specification
  ( VLProperty(VLSelection)
  , PropertySpec
  , LabelledSpec
  , SelectSpec(..)
  , BuildSelectSpecs
  , SelectionLabel
  )


-- | Indicates the type of selection to be generated by the user.

data Selection
    = Single
      -- ^ Allows one mark at a time to be selected.
    | Multi
      -- ^ Allows multiple items to be selected (e.g. with
      --   shift-click).
    | Interval
      -- ^ Allows a bounding rectangle to be dragged by the user,
      --   selecting all items which intersect it.


selectionLabel :: Selection -> T.Text
selectionLabel Single = "single"
selectionLabel Multi = "multi"
selectionLabel Interval = "interval"


{-|

Properties for customising the nature of the selection. See the
<https://vega.github.io/vega-lite/docs/selection.html#selection-properties Vega-Lite documentation>
for details.

For use with 'select' and 'Graphics.Vega.VegaLite.SelectionStyle'.
-}
data SelectionProperty
    = Empty
      -- ^ Make a selection empty by default when nothing selected.
    | BindScales
      -- ^ Enable two-way binding between a selection and the scales used
      --   in the same view. This is commonly used for zooming and panning
      --   by binding selection to position scaling:
      --
      --   @sel = 'selection' . 'select' \"mySelection\" 'Interval' ['BindScales']@
    | BindLegend [BindLegendProperty]
      -- ^ Enable binding between a legend selection and the item it references. This is
      --   only applicable to categorical (symbol) legends. The list of properties
      --   must contain either 'BLField' or 'BLChannel'.
      --
      --   The following will allow the \"crimeType\" legend to be selected:
      --
      --   @
      --   'select' \"mySelection\" 'Single' [ 'BindLegend' [ 'BLField' \"crimeType\" ] ]
      --   @
      --
      --   Use 'On' to make a two-way binding (that is, selecting the legend or the symbol
      --   type will highlight the other):
      --
      --   @
      --   'select' \"sel\" 'Multi' [ 'On' \"click\"
      --                      , 'BindLegend' [ 'BLField' \"crimeType\"
      --                                   , 'BLEvent' \"dblclick\"
      --                                   ]
      --                      ]
      --   @
      --
      --   @since 0.5.0.0
    | On T.Text
      -- ^ [Vega event stream selector](https://vega.github.io/vega/docs/event-streams/#selector)
      --   that triggers a selection, or the empty string (which sets the property to @false@).
    | Clear T.Text
      -- ^ [Vega event stream selector](https://vega.github.io/vega/docs/event-streams/#selector)
      --   that can clear a selection. For example, to allow a zoomed/panned view to be reset
      --   on shift-click:
      --
      -- @
      -- 'selection'
      --     . 'select' \"myZoomPan\"
      --         'Interval'
      --         ['BindScales', 'Clear' \"click[event.shiftKey]\"]
      -- @
      --
      --   To remove the default clearing behaviour of a selection, provide an empty string
      --   rather than an event stream selector.
      --
      --   @since 0.4.0.0
    | Translate T.Text
      -- ^ Translation selection transformation used for panning a view. See the
      --   [Vega-Lite translate documentation](https://vega.github.io/vega-lite/docs/translate.html).
    | Zoom T.Text
      -- ^ Zooming selection transformation used for zooming a view. See the
      --   [Vega-Lite zoom documentation](https://vega.github.io/vega-lite/docs/zoom.html).
    | Fields [FieldName]
      -- ^ Field names for projecting a selection.
    | Encodings [Channel]
      -- ^ Encoding channels that form a named selection.
      --
      --   For example, to __project__ a selection across all items that
      --   share the same value in the color channel:
      --
      --   @sel = 'selection' . 'select' \"mySelection\" 'Multi' ['Encodings' ['Graphics.Vega.VegaLite.ChColor']]@
    | SInit [(FieldName, DataValue)]
      -- ^ Initialise one or more selections with values from bound fields.
      --   See also 'SInitInterval'.
      --
      --   For example,
      --
      --   @
      --   'selection'
      --       . 'select' \"CylYr\"
      --           'Single'
      --           [ 'Fields' [\"Cylinders\", \"Year\"]
      --           , 'SInit'
      --               [ (\"Cylinders\", 'Graphics.Vega.VegaLite.Number' 4)
      --               , (\"Year\", 'Graphics.Vega.VegaLite.Number' 1977)
      --               ]
      --           , 'Bind'
      --               [ 'IRange' \"Cylinders\" ['InMin' 3, 'InMax' 8, 'InStep' 1]
      --               , 'IRange' \"Year\" ['InMin' 1969, 'InMax' 1981, 'InStep' 1]
      --               ]
      --           ]
      --   @
      --
      --   @since 0.4.0.0
    | SInitInterval (Maybe (DataValue, DataValue)) (Maybe (DataValue, DataValue))
      -- ^ Initialize the domain extent of an interval selection. See
      --   also 'SInit'.
      --
      --   The parameters refer to the x and y axes, given in the order
      --   @(minimum, maximum)@ for each axis. If an axis is set to
      --   @Nothing@ then the selection is projected over that
      --   dimension. At least one of the two arguments should be
      --   set (i.e. not @Nothing@).
      --
      --   @
      --   'select' \"mySelection\"
      --          'Interval'
      --          [ 'SInitInterval'
      --              (Just ( 'Graphics.Vega.VegaLite.DateTime' ['Graphics.Vega.VegaLite.DTYear' 2013]
      --                    , 'Graphics.Vega.VegaLite.DateTime' ['Graphics.Vega.VegaLite.DTYear' 2015]
      --                    )
      --              (Just ('Graphics.Vega.VegaLite.Number' 40, 'Graphics.Vega.VegaLite.Number' 80))
      --          ]
      --   @
      --
      --   @since 0.4.0.0
    | ResolveSelections SelectionResolution
      -- ^ Strategy that determines how selections' data queries are resolved when applied
      --   in a filter transform, conditional encoding rule, or scale domain.
    | SelectionMark [SelectionMarkProperty]
      -- ^ Appearance of an interval selection mark (dragged rectangle).
    | Bind [Binding]
      -- ^ Binding to some input elements as part of a named selection.
      --
      --   The followig example allows a selection to be based on a
      --   drop-down list of options:
      --
      --   @
      --   sel = 'selection'
      --           . 'select' \"mySelection\"
      --               'Single'
      --               ['Fields' [\"crimeType\"]
      --               , 'Bind' ['ISelect' \"crimeType\"
      --                         ['InOptions'
      --                            [ \"Anti-social behaviour\"
      --                            , \"Criminal damage and arson\"
      --                            , \"Drugs\"
      --                            , \"Robbery\"
      --                            , \"Vehicle crime\"
      --                            ]
      --                         ]
      --                      ]
      --               ]
      --   @
    | Nearest Bool
      -- ^ Whether or not a selection should capture nearest marks to a pointer
      --   rather than an exact position match.
    | Toggle T.Text
      -- ^ Predicate expression that determines a toggled selection. See the
      --   [Vega-Lite toggle documentation](https://vega.github.io/vega-lite/docs/toggle.html).


selectionProperties :: SelectionProperty -> [LabelledSpec]
selectionProperties (Fields fNames) = ["fields" .= fNames]
selectionProperties (Encodings channels) = ["encodings" .= map channelLabel channels]
selectionProperties (SInit iVals) = ["init" .= object (map (second dataValueSpec) iVals)]
selectionProperties (SInitInterval Nothing Nothing) = []
selectionProperties (SInitInterval mx my) =
  let conv (_, Nothing) = Nothing
      conv (lbl, Just (lo, hi)) = Just (lbl .= [ dataValueSpec lo, dataValueSpec hi ])

  in ["init" .= object (mapMaybe conv (zip ["x", "y"] [mx, my]))]

selectionProperties (On e) = ["on" .= e]
selectionProperties (Clear e) =
  let t = T.strip e
  in ["clear" .= if T.null t then toJSON False else toJSON t]

selectionProperties Empty = ["empty" .= fromT "none"]
selectionProperties (ResolveSelections res) = ["resolve" .= selectionResolutionLabel res]
selectionProperties (SelectionMark markProps) = ["mark" .= object (map selectionMarkProperty markProps)]
selectionProperties BindScales = ["bind" .= fromT "scales"]
selectionProperties (BindLegend blps) =
  let lspecs = map bindLegendProperty blps
  in if "bind" `elem` map fst lspecs
     then lspecs
     else ("bind" .= fromT "legend") : lspecs
selectionProperties (Bind binds) = ["bind" .= object (map bindingSpec binds)]
selectionProperties (Nearest b) = ["nearest" .= b]
selectionProperties (Toggle expr) = ["toggle" .= expr]
selectionProperties (Translate e) = ["translate" .= if T.null e then toJSON False else toJSON e]
selectionProperties (Zoom e) = ["zoom" .= if T.null e then toJSON False else toJSON e]


{-|

Determines how selections in faceted or repeated views are resolved. See the
<https://vega.github.io/vega-lite/docs/selection.html#resolve Vega-Lite documentation>
for details.

For use with 'ResolveSelections'.

-}
data SelectionResolution
    = Global
      -- ^ One selection available across all subviews (default).
    | Union
      -- ^ Each subview contains its own brush and marks are selected if they lie
      --   within /any/ of these individual selections.
    | Intersection
      -- ^  Each subview contains its own brush and marks are selected if they lie
      --    within /all/ of these individual selections.


selectionResolutionLabel :: SelectionResolution -> T.Text
selectionResolutionLabel Global = "global"
selectionResolutionLabel Union = "union"
selectionResolutionLabel Intersection = "intersect"


{-|

Properties for customising the appearance of an interval selection
mark (a dragged rectangle). For details see the
<https://vega.github.io/vega-lite/docs/selection.html#interval-mark Vega-Lite documentation>.

-}
data SelectionMarkProperty
    = SMFill Color
      -- ^ Fill color.
    | SMFillOpacity Opacity
      -- ^ Fill opacity.
    | SMStroke Color
      -- ^ The stroke color.
    | SMStrokeOpacity Opacity
      -- ^ The stroke opacity.
    | SMStrokeWidth Double
      -- ^ The line width of the stroke.
    | SMStrokeDash DashStyle
      -- ^ The dash pattern for the stroke.
    | SMStrokeDashOffset DashOffset
      -- ^ The offset at which to start the dash pattern.


selectionMarkProperty :: SelectionMarkProperty -> LabelledSpec
selectionMarkProperty (SMFill colour) = "fill" .= fromColor colour
selectionMarkProperty (SMFillOpacity x) = "fillOpacity" .= x
selectionMarkProperty (SMStroke colour) = "stroke" .= fromColor colour
selectionMarkProperty (SMStrokeOpacity x) = "strokeOpacity" .= x
selectionMarkProperty (SMStrokeWidth x) = "strokeWidth" .= x
selectionMarkProperty (SMStrokeDash xs) = "strokeDash" .= fromDS xs
selectionMarkProperty (SMStrokeDashOffset x) = "strokeDashOffset" .= x


{-|

GUI Input properties. The type of relevant property will depend on the type of
input element selected. For example an @InRange@ (slider) can have numeric min,
max and step values; @InSelect@ (selector) has a list of selection label options.
For details see the
<https://vega.github.io/vega/docs/signals/#bind Vega input element binding documentation>.

-}

-- based on schema 3.3.0 #/definitions/BindRange
--       or              #/definitions/InputBinding

-- placeholder is in InputBinding
-- debounce is in BindCheckbox / BindRadioSelect / BindRange / InputBinding
-- element is in BindCheckbox / BindRadioSelect / BindRange / InputBinding

-- but InputBinding doesn't have min/max/others

data InputProperty
    = Debounce Double
      -- ^ The delay to introduce when processing input events to avoid
      --   unnescessary event broadcasting.
    | Element T.Text
      -- ^ CSS selector indicating the parent element to which an input
      --   element should be added. This allows for interacting with
      --   elements outside the visualization container.
    | InOptions [T.Text]
      -- ^ The options for a radio or select input element.
    | InMin Double
      -- ^ The minimum slider value for a range input element.
    | InMax Double
      -- ^ The maximum slider value for a range input element.
    | InName T.Text
      -- ^ Custom label for a radio or select input element.
    | InStep Double
      -- ^ The minimum increment for a range sliders.
    | InPlaceholder T.Text
      -- ^ The initial text for input elements such as text fields.


inputProperty :: InputProperty -> LabelledSpec
inputProperty (Debounce x) = "debounce" .= x
inputProperty (Element el) = "element" .= el -- #/definitions/Element
inputProperty (InOptions opts) = "options" .= map toJSON opts
inputProperty (InMin x) = "min" .= x
inputProperty (InMax x) = "max" .= x
inputProperty (InName s) = "name" .= s
inputProperty (InStep x) = "step" .= x
inputProperty (InPlaceholder el) = "placeholder" .= toJSON el


{-|

Describes the binding property of a selection based on some HTML input element
such as a checkbox or radio button. For details see the
<https://vega.github.io/vega-lite/docs/bind.html#scale-binding Vega-Lite documentation>
and the
<https://vega.github.io/vega/docs/signals/#bind Vega input binding documentation>.
-}
data Binding
    = IRange T.Text [InputProperty]
      -- ^ Range slider input element that can bound to a named field value.
    | ICheckbox T.Text [InputProperty]
      -- ^ Checkbox input element that can bound to a named field value.
    | IRadio T.Text [InputProperty]
      -- ^ Radio box input element that can bound to a named field value.
    | ISelect T.Text [InputProperty]
      -- ^ Select input element that can bound to a named field value.
    | IText T.Text [InputProperty]
      -- ^ Text input element that can bound to a named field value.
    | INumber T.Text [InputProperty]
      -- ^ Number input element that can bound to a named field value.
    | IDate T.Text [InputProperty]
      -- ^ Date input element that can bound to a named field value.
    | ITime T.Text [InputProperty]
      -- ^ Time input element that can bound to a named field value.
    | IMonth T.Text [InputProperty]
      -- ^ Month input element that can bound to a named field value.
    | IWeek T.Text [InputProperty]
      -- ^ Week input element that can bound to a named field value.
    | IDateTimeLocal T.Text [InputProperty]
      -- ^ Local time input element that can bound to a named field value.
    | ITel T.Text [InputProperty]
      -- ^ Telephone number input element that can bound to a named field value.
    | IColor T.Text [InputProperty]
      -- ^ Color input element that can bound to a named field value.


bindingSpec :: Binding -> LabelledSpec
bindingSpec bnd =
  let (lbl, input, ps) = case bnd of
        IRange label props -> (label, fromT "range", props)
        ICheckbox label props -> (label, "checkbox", props)
        IRadio label props -> (label, "radio", props)
        ISelect label props -> (label, "select", props)
        IText label props -> (label, "text", props)
        INumber label props -> (label, "number", props)
        IDate label props -> (label, "date", props)
        ITime label props -> (label, "time", props)
        IMonth label props -> (label, "month", props)
        IWeek label props -> (label, "week", props)
        IDateTimeLocal label props -> (label, "datetimelocal", props)
        ITel label props -> (label, "tel", props)
        IColor label props -> (label, "color", props)

  in (lbl, object (("input" .= input) : map inputProperty ps))


{-|

Control the interactivity of the legend. This is used with 'BindLegend'.

@since 0.5.0.0

-}
data BindLegendProperty
  = BLField FieldName
    -- ^ The data field which should be made interactive in the legend.
  | BLChannel Channel
    -- ^ Which channel should be made interactive in a legend.
  | BLEvent T.Text
    -- ^ The <https://vega.github.io/vega/docs/event-streams Vega event stream>
    --   that should trigger an interactive legend selection. If not specified,
    --   the default is to use a single click.


bindLegendProperty :: BindLegendProperty -> LabelledSpec
bindLegendProperty (BLField f) = "fields" .= [f]
bindLegendProperty (BLChannel ch) = "encodings" .= [channelLabel ch]
bindLegendProperty (BLEvent es) = "bind" .= object ["legend" .= es]


{-|

Create a full selection specification from a list of selections. For details
see the
<https://vega.github.io/vega-lite/docs/selection.html Vega-Lite documentation>.

@
sel =
   'selection'
       . 'select' \"view\" 'Interval' ['BindScales'] []
       . 'select' \"myBrush\" 'Interval' []
       . 'select' \"myPaintbrush\" 'Multi' ['On' \"mouseover\", 'Nearest' True]
@

-}

selection ::
  [SelectSpec]
  -- ^ The arguments created by 'Graphics.Vega.VegaLite.select'.
  --
  --   Prior to @0.5.0.0@ this argument was @['LabelledSpec']@.
  -> PropertySpec
selection sels = (VLSelection, object (map unS sels))


{-|

Create a single named selection that may be applied to a data query or
transformation.

@
sel =
    'selection'
        . 'select' "view" 'Interval' [ 'BindScales' ] []
        . 'select' "myBrush" 'Interval' []
        . 'select' "myPaintbrush" 'Multi' [ 'On' "mouseover", 'Nearest' True ]
@

-}
select ::
  SelectionLabel
  -- ^ The name given to the selection.
  -> Selection
  -- ^ The type of the selection.
  -> [SelectionProperty]
  -- ^ What options are applied to the selection.
  -> BuildSelectSpecs
  -- ^ Prior to @0.5.0.0@ this was @BuildLabelledSpecs@.
select nme sType options ols =
  -- TODO: elm filters out those properties that are set to A.Null
  let selProps = ("type" .= selectionLabel sType) : concatMap selectionProperties options
  in S (nme .= object selProps) : ols
