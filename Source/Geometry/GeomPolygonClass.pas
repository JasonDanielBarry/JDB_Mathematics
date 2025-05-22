unit GeomPolygonClass;

interface

    uses
        System.SysUtils, system.Math,
        GeometryTypes,
        GeometryMathMethods,
        GeomLineClass,
        GeomPolyLineClass;

    type
        TGeomPolygon = class(TGeomPolyLine)
            public
                //constructor
                    constructor create();
                //destructor
                    destructor destroy(); override;
                //calculations
                    function calculateCentroidPoint() : TGeomPoint; override;
                    function calculatePerimeter() : double;
                    function calculatePolygonArea() : double; overload;
                    class function calculatePolygonCentroid(const arrPointsIn : TArray<TGeomPoint>) : TGeomPoint; static;
                    class function calculatePolygonArea(const arrPointsIn : TArray<TGeomPoint>) : double; overload; static;
        end;

implementation

    //public
        //constructor
            constructor TGeomPolygon.create();
                begin
                    inherited create();
                end;

        //destructor
            destructor TGeomPolygon.destroy();
                begin
                    inherited destroy();
                end;

        //calculations
            function TGeomPolygon.calculateCentroidPoint() : TGeomPoint;
                begin
                    result := calculatePolygonCentroid( arrGeomPoints );
                end;

            function TGeomPolygon.calculatePerimeter() : double;
                var
                    closingLineLength,
                    polylineLength          : double;
                    closingLineStartPoint,
                    closingLineEndPoint    : TGeomPoint;
                begin
                    //get the polyline length
                        polylineLength := calculatePolylineLength();

                    //calculate the closing line length------------------------------------------------------------------
                        //start point is the polyline last vertex
                            closingLineStartPoint := arrGeomPoints[vertexCount() - 1];

                        //end point is polyline first vertex
                            closingLineEndPoint := arrGeomPoints[0];

                        //get the length
                            closingLineLength := TGeomPoint.calculateDistanceBetweenPoints( closingLineStartPoint, closingLineEndPoint );
                    //---------------------------------------------------------------------------------------------------

                    //the polygon perimeter = polyline length + closing line length
                        result := closingLineLength + polylineLength;
                end;

            function TGeomPolygon.calculatePolygonArea() : double;
                begin
                    result := calculatePolygonArea( arrGeomPoints );
                end;

            class function TGeomPolygon.calculatePolygonCentroid(const arrPointsIn : TArray<TGeomPoint>) : TGeomPoint;
                var
                    i, arrLen                       : integer;
                    centroidX, centroidY, centroidZ,
                    triangleArea, totalArea         : double;
                    triangleCentroidPoint           : TGeomPoint;
                    arr_XdA, arr_YdA, arr_ZdA       : TArray<double>;
                begin
                    arrLen      := length( arrPointsIn );
                    totalArea   := calculatePolygonArea( arrPointsIn );

                    SetLength( arr_XdA, arrLen );
                    SetLength( arr_YdA, arrLen );
                    SetLength( arr_ZdA, arrLen );

                    for i := 0 to ( arrLen - 1 ) do
                        begin
                            triangleCentroidPoint   := geomTriangleCentroid( arrPointsIn[i], arrPointsIn[ (i+1) mod arrlen ] );
                            triangleArea            := geomTriangleArea( arrPointsIn[i], arrPointsIn[ (i+1) mod arrlen ] );

                            arr_XdA[i] := triangleCentroidPoint.x * triangleArea;
                            arr_YdA[i] := triangleCentroidPoint.y * triangleArea;
                            arr_ZdA[i] := triangleCentroidPoint.z * triangleArea;
                        end;

                    centroidX := sum( arr_XdA ) / totalArea;
                    centroidY := sum( arr_YdA ) / totalArea;
                    centroidZ := sum( arr_ZdA ) / totalArea;

                    result := TGeomPoint.create( centroidX, centroidY, centroidZ );
                end;

            class function TGeomPolygon.calculatePolygonArea(const arrPointsIn : TArray<TGeomPoint>) : double;
                var
                    i, arrLen   : integer;
                    areaSum     : double;
                begin
                    //this function uses the Shoelace formula calculation

                    areaSum := 0;

                    arrLen := Length( arrPointsIn );

                    //shoelace calculation
                        for i := 0 to (arrLen - 1) do
                            areaSum := areaSum + geomTriangleArea(arrPointsIn[i], arrPointsIn[ (i+1) mod arrlen ]);

                    result := areaSum;
                end;

end.
