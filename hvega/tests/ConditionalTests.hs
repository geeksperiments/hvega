{-# LANGUAGE OverloadedStrings #-}

--
-- Based on the Elm VegaLite ConditionalTests.elm as of version 1.12.0
--
module ConditionalTests (testSpecs) where

import Graphics.Vega.VegaLite

import Data.Function ((&))
import Prelude hiding (filter)

testSpecs :: [(String, VegaLite)]
testSpecs = [ ("markCondition1", markCondition1)
            , ("markCondition2", markCondition2)
            , ("axisCondition1", axisCondition1)
            , ("axisCondition2", axisCondition2)
            , ("axisCondition3", axisCondition3)
            , ("axisDateCondition1", axisDateCondition1)
            , ("selectionCondition1", selectionCondition1)
            , ("selectionCondition2", selectionCondition2)
            , ("selectionCondition3", selectionCondition3)
            , ("selectionCondition4", selectionCondition4)
            , ("selectionCondition5", selectionCondition5)
            , ("bindScales1", bindScales1)
            , ("bindScales2", bindScales2)
            ]
            
markCondition1 :: VegaLite
markCondition1 =
    let
        dataVals =
            dataFromUrl "https://vega.github.io/vega-lite/data/movies.json" []

        config =
            configure
                . configuration (MarkStyle [ MRemoveInvalid False ])

        enc =
            encoding
                . position X [ PName "IMDB_Rating", PmType Quantitative ]
                . position Y [ PName "Rotten_Tomatoes_Rating", PmType Quantitative ]
                . color
                    [ MDataCondition
                        [ ( Or (Expr "datum.IMDB_Rating === null")
                            (Expr "datum.Rotten_Tomatoes_Rating === null")
                          ,  [ MString "#ddd" ]
                          )
                        ]
                        [ MString "#0099ee" ]
                    ]
    in
    toVegaLite [ config []
               , dataVals
               -- Vega-Lite 4 turned off tooltips by default, so
               -- enable them here
               , mark Point [ MTooltip TTEncoding ]
               , enc [] ]


markCondition2 :: VegaLite
markCondition2 =
    let
        dataVals =
            dataFromColumns []
                . dataColumn "value" (Numbers [ 10, 20, 30, 40, 50, 60 ])

        enc =
            encoding
                . position X [ PName "value", PmType Ordinal ]
                . color
                    [ MDataCondition
                        [ ( Expr "datum.value < 40", [ MString "blue" ] )
                        , ( Expr "datum.value < 50", [ MString "red" ] )
                        , ( Expr "datum.value < 60", [ MString "yellow" ] )
                        ]
                        [ MString "black" ]
                    ]
    in
    toVegaLite [ width 400, dataVals [], mark Circle [ MSize 800 ], enc [] ]


axisTest :: [AxisProperty] -> VegaLite
axisTest axConds =
  let dvals = dataFromUrl "https://vega.github.io/vega-lite/data/movies.json" []

      enc = encoding
                . position X
                    [ PName "IMDB_Rating"
                    , PmType Quantitative
                    , PAxis (AxTickCount 20 : axConds)
                    ]
                . position Y [ PName "Rotten_Tomatoes_Rating", PmType Quantitative ]

  in toVegaLite [ width 600, height 600, dvals, mark Point [ MOpacity 0.1 ], enc [] ]


axisCondition1 :: VegaLite
axisCondition1 =
  axisTest [ AxDataCondition (Expr "datum.value <= 5") (CAxGridDash [ 5, 5 ] [])
           , AxDataCondition (Expr "datum.value <= 7") (CAxGridColor "green" "red")
           ]


axisCondition2 :: VegaLite
axisCondition2 =
  axisTest [ AxDataCondition (Expr "datum.value <= 2") (CAxTickColor "red" "blue")
           , AxDataCondition (Expr "datum.value >=8") (CAxTickOpacity 0.3 0.8)
           , AxDataCondition (Expr "datum.label =='4.0'") (CAxTickWidth 5 2)
           , AxDataCondition (Expr "(datum.value >= 5) && (datum.value <= 8)")
                              (CAxTickDash [2, 2] [])
           {- Vega-Embed (Early Jan 2020) doesn't seem to display this well
           , AxDataCondition (Expr "(datum.value >= 3) && (datum.value <= 7)")
                              (CAxTickDashOffset 4 0)
           -}
           ]


axisCondition3 :: VegaLite
axisCondition3 =
  axisTest [ AxDataCondition (Expr "datum.value <= 2") (CAxLabelColor "red" "blue")
           -- , AxDataCondition (Expr "datum.value <= 1") (CAxLabelAlign AlignRight AlignLeft)
           , AxDataCondition (Expr "datum.value <= 3") (CAxLabelBaseline AlignTop AlignBottom)
           , AxDataCondition (Expr "datum.value <= 4") (CAxLabelFont "serif" "sans-serif")
           , AxDataCondition (Expr "datum.value <= 6") (CAxLabelFontSize 12 18)
           , AxDataCondition (Expr "datum.value <=8") (CAxLabelFontStyle "normal" "italic")
           , AxDataCondition (Expr "datum.label =='4.0'") (CAxLabelFontWeight Bold W100)
           , AxDataCondition (Expr "datum.value >=9") (CAxLabelOpacity 0.3 0.8)
           ]


-- add a basic test of date handling (so that I can check the example given in the
-- documentation, or at least one similar to it, even if in this case it affects
-- all grid lines).
--
axisDateCondition1 :: VegaLite
axisDateCondition1 =
  let dataVals = dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

      enc =
        encoding
          . position X [ PName "Year"
                       , PmType Temporal
                       , PTimeUnit Year
                       , PAxis [ AxDataCondition
                                 (FEqual "value" (DateTime [DTMonth Jan, DTDate 1])
                                   & FilterOpTrans (MTimeUnit MonthDate))
                                 (CAxGridWidth 4 1)
                               ]
                       ]
          . position Y [ PName "Miles_per_Gallon"
                       , PmType Quantitative
                       , PScale [ SZero False ]
                       ]

      mopts = [ MExtent Iqr, MInterpolate Monotone, MBorders [] ]

  in toVegaLite [ width 600, dataVals, enc [], mark ErrorBand mopts ]


selectionCondition1 :: VegaLite
selectionCondition1 =
    let dataVals =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

        sel =
            selection
                . select "alex"
                    Interval
                    [ On "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    , Translate "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    ]
                . select "morgan"
                    Interval
                    [ On "[mousedown[event.shiftKey], mouseup] > mousemove"
                    , Translate "[mousedown[event.shiftKey], mouseup] > mousemove"
                    , SelectionMark [ SMFill "#fdbb84", SMFillOpacity 0.5, SMStroke "#e34a33" ]
                    ]

        enc =
            encoding
                . position Y [ PName "Origin", PmType Ordinal ]
                . position X [ PName "Cylinders", PmType Ordinal ]
                . color [ MAggregate Count, MName "*", MmType Quantitative ]
    in
    toVegaLite
        [ dataVals, sel [], mark Rect [ MCursor CGrab ], enc [] ]


selectionCondition2 :: VegaLite
selectionCondition2 =
    let
        dataVals =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

        sel =
            selection
                . select "alex"
                    Interval
                    [ On "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    , Translate "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    ]
                . select "morgan"
                    Interval
                    [ On "[mousedown[event.shiftKey], mouseup] > mousemove"
                    , Translate "[mousedown[event.shiftKey], mouseup] > mousemove"
                    , SelectionMark [ SMFill "#fdbb84", SMFillOpacity 0.5, SMStroke "#e34a33" ]
                    ]

        enc =
            encoding
                . position Y [ PName "Origin", PmType Ordinal ]
                . position X [ PName "Cylinders", PmType Ordinal ]
                . color
                    [ MSelectionCondition
                        (And (SelectionName "alex") (SelectionName "morgan"))
                        [ MAggregate Count, MName "*", MmType Quantitative ]
                        [ MString "gray" ]
                    ]
    in
    toVegaLite
        [ dataVals, sel [], mark Rect [ MCursor CGrab ], enc [] ]


selectionCondition3 :: VegaLite
selectionCondition3 =
    let
        dataVals =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

        trans =
            transform
                . filter (FCompose (And (Selection "brush") (Expr "datum.Weight_in_lbs > 3000")))

        sel =
            selection
                . select "brush" Interval []

        enc1 =
            encoding
                . position X [ PName "Horsepower", PmType Quantitative ]
                . position Y [ PName "Miles_per_Gallon", PmType Quantitative ]

        spec1 =
            asSpec [ sel [], mark Point [], enc1 [] ]

        enc2 =
            encoding
                . position X [ PName "Acceleration", PmType Quantitative, PScale [ SDomain (DNumbers [ 0, 25 ]) ] ]
                . position Y [ PName "Displacement", PmType Quantitative, PScale [ SDomain (DNumbers [ 0, 500 ]) ] ]

        spec2 =
            asSpec [ trans [], mark Point [], enc2 [] ]
    in
    toVegaLite
        [ dataVals, vConcat [ spec1, spec2 ] ]


selectionCondition4 :: VegaLite
selectionCondition4 =
    let
        dataVals =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

        sel =
            selection
                . select "mySelection"
                    Interval
                    [ Clear ""
                    , On "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    , Translate "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    ]

        enc =
            encoding
                . position Y [ PName "Origin", PmType Ordinal ]
                . position X [ PName "Cylinders", PmType Ordinal ]
                . color
                    [ MSelectionCondition
                        (SelectionName "mySelection")
                        [ MAggregate Count, MName "*", MmType Quantitative ]
                        [ MString "gray" ]
                    ]
    in
    toVegaLite
        [ dataVals, sel [], mark Rect [ MCursor CGrab ], enc [] ]


selectionCondition5 :: VegaLite
selectionCondition5 =
    let
        dataVals =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

        sel =
            selection
                . select "mySelection"
                    Interval
                    [ Clear "mouseup"
                    , Empty
                    , On "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    , Translate "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    ]

        enc =
            encoding
                . position Y [ PName "Origin", PmType Ordinal ]
                . position X [ PName "Cylinders", PmType Ordinal ]
                . color
                    [ MSelectionCondition
                        (SelectionName "mySelection")
                        [ MAggregate Count, MName "*", MmType Quantitative ]
                        [ MString "gray" ]
                    ]
    in
    toVegaLite
        [ dataVals, sel [], mark Rect [ MCursor CGrab ], enc [] ]


bindScales1 :: VegaLite
bindScales1 =
    let
        dataVals =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json"

        sel =
            selection
                . select "myZoomPan" Interval [ BindScales ]

        enc =
            encoding
                . position X [ PName "Horsepower", PmType Quantitative ]
                . position Y [ PName "Miles_per_Gallon", PmType Quantitative ]
    in
    toVegaLite
        [ width 300, height 300, dataVals [], sel [], mark Circle [], enc [] ]


bindScales2 :: VegaLite
bindScales2 =
    let
        dataVals =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json"

        sel =
            selection
                . select "myZoomPan"
                    Interval
                    [ BindScales, Clear "click[event.shiftKey]" ]

        enc =
            encoding
                . position X [ PName "Horsepower", PmType Quantitative ]
                . position Y [ PName "Miles_per_Gallon", PmType Quantitative ]
    in
    toVegaLite
        [ width 300, height 300, dataVals [], sel [], mark Circle [], enc [] ]
