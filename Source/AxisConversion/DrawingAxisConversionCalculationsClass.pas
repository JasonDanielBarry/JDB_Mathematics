unit DrawingAxisConversionCalculationsClass;

interface

    uses
        System.SysUtils, system.Math, system.Types,
        LinearInterpolationMethods,
        GeometryTypes, GeomBox,
        DrawingAxisConversionBaseClass
        ;

    type
        TDrawingAxisConvertionCalculator = class(TDrawingAxisConverterBase)
            private
                //canvas-to-drawing
                    function L_to_X(const L_In : double) : double;
                    function T_to_Y(const T_In : double) : double;
                //drawing-to-canvas
                    function X_to_L(const X_In : double) : double;
                    function Y_to_T(const Y_In : double) : double;
                //canvas-to-drawing
                    function LT_to_XY(const L_In, T_In : double) : TGeomPoint; overload;
                //drawing-to-canvas
                    function XY_to_LT(const X_In, Y_In : double) : TPointF; overload;
            public
                //constructor
                    constructor create(); override;
                //destructor
                    destructor destroy(); override;
                //space conversions
                    //canvas to region
                        function dL_To_dX(const dL_In : double) : double;
                        function dT_To_dY(const dT_In : double) : double;
                    //region to canvas
                        function dX_To_dL(const dX_In : double) : double;
                        function dY_To_dT(const dY_In : double) : double;
                //convertion calculations
                    //canvas-to-drawing
                        function LT_to_XY(const pointIn : TPointF) : TGeomPoint; overload;
                        function LT_to_XY(const pointIn : TPoint) : TGeomPoint; overload;
                        function arrLT_to_arrXY(const arrLT_In : TArray<TPointF>) : TArray<TGeomPoint>; overload;
                        function arrLT_to_arrXY(const arrLT_In : TArray<TPoint>) : TArray<TGeomPoint>; overload;
                    //drawing-to-canvas
                        function XY_to_LT(const pointIn : TGeomPoint) : TPointF; overload;
                        function arrXY_to_arrLT(const arrXY_In : TArray<TGeomPoint>) : TArray<TPointF>;
        end;

implementation

    //private
        //canvasSpace-to-drawing
            function TDrawingAxisConvertionCalculator.L_to_X(const L_In : double) : double;
                begin
                    result := linearInterpolate(
                                                    L_In,
                                                    0,                      drawingRegion.xMin,
                                                    canvasDimensions.Width, drawingRegion.xMax
                                               );
                end;

            function TDrawingAxisConvertionCalculator.T_to_Y(const T_In : double) : double;
                begin
                    result := linearInterpolate(
                                                    T_In,
                                                    0,                          drawingRegion.yMax,
                                                    canvasDimensions.Height,    drawingRegion.yMin
                                               );
                end;

        //drawing-to-canvas
            function TDrawingAxisConvertionCalculator.X_to_L(const X_In : double) : double;
                begin
                    result := linearInterpolate(
                                                    X_In,
                                                    drawingRegion.xMin, 0,
                                                    drawingRegion.xMax, canvasDimensions.Width
                                               );
                end;

            function TDrawingAxisConvertionCalculator.Y_to_T(const Y_In : double) : double;
                begin
                    result := linearInterpolate(
                                                    Y_In,
                                                    drawingRegion.yMin, canvasDimensions.Height,
                                                    drawingRegion.yMax, 0
                                               );
                end;

        //canvasSpace-to-drawing
            function TDrawingAxisConvertionCalculator.LT_to_XY(const L_In, T_In : double) : TGeomPoint;
                begin
                    result.setPoint(
                                        L_to_X(L_In),
                                        T_to_Y(T_In)
                                   );
                end;

        //drawing-to-canvas
            function TDrawingAxisConvertionCalculator.XY_to_LT(const X_In, Y_In : double) : TPointF;
                begin
                    result := PointF(
                                        X_to_L(X_In),
                                        Y_to_T(Y_In)
                                    );
                end;

    //public
        //constructor
            constructor TDrawingAxisConvertionCalculator.create();
                begin
                    inherited create();
                end;

        //destructor
            destructor TDrawingAxisConvertionCalculator.destroy();
                begin
                    inherited destroy();
                end;

        //space conversions
            //canvas to region
                function TDrawingAxisConvertionCalculator.dL_To_dX(const dL_In : double) : double;
                    begin
                        //dx/dl = (D/w)
                        //dx = dl(D/w)

                        result := dL_In * (drawingRegion.calculateXDimension() / canvasDimensions.Width);
                    end;

                function TDrawingAxisConvertionCalculator.dT_To_dY(const dT_In : double) : double;
                    begin
                        //dy/dt = -(R/h)
                        //dy = -dt(R/h)

                        result := -dT_In * (drawingRegion.calculateYDimension() / canvasDimensions.Height);
                    end;

            //region to canvas
                function TDrawingAxisConvertionCalculator.dX_To_dL(const dX_In : double) : double;
                    begin
                        //dl/dx = (w/D)

                        result := dX_In * (canvasDimensions.Width / drawingRegion.calculateXDimension());
                    end;

                function TDrawingAxisConvertionCalculator.dY_To_dT(const dY_In : double) : double;
                    begin
                        //dt/dy = -(h/R)

                        result := -dY_In * (canvasDimensions.Height / drawingRegion.calculateYDimension());
                    end;

        //convertion calculations
            //canvasSpace-to-drawing
                function TDrawingAxisConvertionCalculator.LT_to_XY(const pointIn : TPointF) : TGeomPoint;
                    begin
                        result := LT_to_XY(pointIn.X, pointIn.Y);
                    end;

                function TDrawingAxisConvertionCalculator.LT_to_XY(const pointIn : TPoint) : TGeomPoint;
                    var
                        newPoint : TPointF;
                    begin
                        newPoint := TPointF.create(pointIn);

                        result := LT_to_XY(newPoint);
                    end;

                function TDrawingAxisConvertionCalculator.arrLT_to_arrXY(const arrLT_In : TArray<TPointF>) : TArray<TGeomPoint>;
                    var
                        i, arrLen       : integer;
                        arrPointsOut    : TArray<TGeomPoint>;
                    begin
                        arrLen := length(arrLT_In);

                        SetLength(arrPointsOut, arrLen);

                        for i := 0 to (arrLen - 1) do
                            arrPointsOut[i] := LT_to_XY(arrLT_In[i]);

                        result := arrPointsOut;
                    end;

                function TDrawingAxisConvertionCalculator.arrLT_to_arrXY(const arrLT_In : TArray<TPoint>) : TArray<TGeomPoint>;
                    var
                        i               : integer;
                        arrPointF       : TArray<TPointF>;
                    begin
                        SetLength(arrPointF, length(arrLT_In));

                        for i := 0 to (length(arrPointF) - 1) do
                            arrPointF[i] := TPointF.create(arrLT_In[i]);

                        result := arrLT_to_arrXY(arrPointF);
                    end;

            //drawing-to-canvas
                function TDrawingAxisConvertionCalculator.XY_to_LT(const pointIn : TGeomPoint) : TPointF;
                    begin
                        result := XY_to_LT(pointIn.x, pointIn.y);
                    end;

                function TDrawingAxisConvertionCalculator.arrXY_to_arrLT(const arrXY_In : TArray<TGeomPoint>) : TArray<TPointF>;
                    var
                        i, arrLen       : integer;
                        arrPointsOut    : TArray<TPointF>;
                    begin
                        arrLen := length(arrXY_In);

                        SetLength(arrPointsOut, arrLen);

                        for i := 0 to (arrLen - 1) do
                            arrPointsOut[i] := XY_to_LT(arrXY_In[i]);

                        result := arrPointsOut;
                    end;

end.
