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
                    function calculatePerimeter() : double;
                    function calculatePolygonArea() : double; overload;
                    class function calculatePolygoneArea(const arrPointsIn : TArray<TGeomPoint>) : double; overload; static;
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
                    result := calculatePolygoneArea( arrGeomPoints );
                end;

            class function TGeomPolygon.calculatePolygoneArea(const arrPointsIn : TArray<TGeomPoint>) : double;
                var
                    i, arrLen   : integer;
                    areaSum     : double;
                begin
                    //this function uses the Shoelace formula calculation

                    areaSum := 0;

                    arrLen := Length(arrPointsIn);

                    //shoelace calculation
                        for i := 0 to (arrLen - 2) do
                            areaSum := areaSum + geomTriangleArea(arrPointsIn[i], arrPointsIn[i + 1]);

                        areaSum := areaSum + geomTriangleArea(arrPointsIn[arrLen - 1], arrPointsIn[0]);

                    result := areaSum;
                end;

end.
