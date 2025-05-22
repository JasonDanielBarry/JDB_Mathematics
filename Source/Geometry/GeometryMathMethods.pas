unit GeometryMathMethods;

interface

    uses
        System.SysUtils, system.Math, system.Types,
        LineIntersectionMethods,
        LinearAlgebraTypes,
        MatrixMethods,
        GeometryTypes,
        GeomBox
        ;

   
    //calculate triangle area
        //given three vertices
            function geomTriangleArea(const point1In, point2In, point3In : TGeomPoint) : double; overload;

        //given two vertices
            function geomTriangleArea(const point1In, point2In : TGeomPoint) : double; overload;

    //calculate trianlge centroid
        //given three vertices
            function geomTriangleCentroid(const point1In, point2In, point3In : TGeomPoint) : TGeomPoint; overload;

        //given two vertices
            function geomTriangleCentroid(const point1In, point2In : TGeomPoint) : TGeomPoint; overload;

    //calculate the intersection point of two lines
        function geomLineIntersectionPoint( const   line1StartPointIn, line1EndPointIn,
                                                    line2StartPointIn, line2EndPointIn  : TGeomPoint) : TGeomLineIntersectionData;

implementation

       
    //calculate triangle area
        //helper method
            function triangleArea(const x1, y1,
                                        x2, y2,
                                        x3, y3  : double) : double;
                var
                    coordinateMatrix : TLAMatrix;
                begin
                    coordinateMatrix := [
                                            [x1, y1, 1],
                                            [x2, y2, 1],
                                            [x3, y3, 1]
                                        ];

                    result := 0.5 * matrixDeterminant( coordinateMatrix );
                end;

        //given three vertices
            function geomTriangleArea(const point1In, point2In, point3In : TGeomPoint) : double;
                var
                    x1, y1,
                    x2, y2,
                    x3, y3 : double;
                begin
                    //extract values from points
                        x1 := point1In.x;
                        y1 := point1In.y;

                        x2 := point2In.x;
                        y2 := point2In.y;

                        x3 := point3In.x;
                        y3 := point3In.y;

                    result := triangleArea( x1, y1,
                                            x2, y2,
                                            x3, y3  );
                end;

        //given two vertices
            function geomTriangleArea(const point1In, point2In : TGeomPoint) : double;
                var
                    point3 : TGeomPoint;
                begin
                    point3 := TGeomPoint.create(0, 0);

                    result := geomTriangleArea(point1In, point2In, point3);
                end;

    //calculate trianlge centroid
        //given three vertices
            function geomTriangleCentroid(const point1In, point2In, point3In : TGeomPoint) : TGeomPoint;
                begin
                    result := TGeomPoint.calculateCentroidPoint( [ point1In, point2In, point3In ] );
                end;

        //given two vertices
            function geomTriangleCentroid(const point1In, point2In : TGeomPoint) : TGeomPoint;
                begin
                    result := geomTriangleCentroid( TGeomPoint.create( 0, 0 ), point1In, point2In );
                end;

    //calculate the intersection point of two lines
        function calculateLineIntersectionPoint(out     linesIntersectOut                   : boolean;
                                                const   line1StartPointIn, line1EndPointIn,
                                                        line2StartPointIn, line2EndPointIn  : TGeomPoint) : TGeomPoint;
            var
                l1x0, l1y0, l1x1, l1y1,
                l2x0, l2y0, l2x1, l2y1  : double;
                intersectionPoint       : TPointF;
            begin
                //line 1 info
                    l1x0 := line1StartPointIn.x;
                    l1y0 := line1StartPointIn.y;
                    l1x1 := line1EndPointIn.x;
                    l1y1 := line1EndPointIn.y;

                //line 2 info
                    l2x0 := line2StartPointIn.x;
                    l2y0 := line2StartPointIn.y;
                    l2x1 := line2EndPointIn.x;
                    l2y1 := line2EndPointIn.y;

                intersectionPoint := lineIntersectionPoint( linesIntersectOut,
                                                            l1x0, l1y0, l1x1, l1y1,
                                                            l2x0, l2y0, l2x1, l2y1  );

                result := TGeomPoint.create( intersectionPoint );
            end;

        function determineLineIntersectionRegion(const  intersectionPointIn,
                                                        line1StartPointIn, line1EndPointIn,
                                                        line2StartPointIn, line2EndPointIn  : TGeomPoint) : EBoundaryRelation;
            var
                isWithinLine1,  isWithinLine2   : boolean;
                line1Bound,     line2Bound      : TGeomBox;
                boundaryRelationOut             : EBoundaryRelation;
            begin
                //get line bounding boxes
                    line1Bound := TGeomBox.create( line1StartPointIn, line1EndPointIn );
                    line2Bound := TGeomBox.create( line2StartPointIn, line2EndPointIn );

                //test if point is on either line
                    isWithinLine1 := line1Bound.pointIsWithin( intersectionPointIn );
                    isWithinLine2 := line2Bound.pointIsWithin( intersectionPointIn );

                //test if the intersection point lies within the boundaries of the two lines
                    if (isWithinLine1 OR isWithinLine2) then
                        boundaryRelationOut := EBoundaryRelation.brInside
                    else
                        boundaryRelationOut := EBoundaryRelation.brOutside;

                result := boundaryRelationOut;
            end;

        function geomLineIntersectionPoint( const   line1StartPointIn, line1EndPointIn,
                                                    line2StartPointIn, line2EndPointIn  : TGeomPoint) : TGeomLineIntersectionData;
            var
                intersectionDataOut : TGeomLineIntersectionData;
            begin
                //calculate the intersection point
                    intersectionDataOut.point := calculateLineIntersectionPoint(    intersectionDataOut.intersectionExists,
                                                                                    line1StartPointIn, line1EndPointIn,
                                                                                    line2StartPointIn, line2EndPointIn                );

                //determine where the intersection lies
                    if (intersectionDataOut.intersectionExists) then
                        begin
                            intersectionDataOut.relativeToBound := determineLineIntersectionRegion( intersectionDataOut.point,
                                                                                                    line1StartPointIn, line1EndPointIn,
                                                                                                    line2StartPointIn, line2EndPointIn    );
                        end;

                result := intersectionDataOut;
            end;


end.
