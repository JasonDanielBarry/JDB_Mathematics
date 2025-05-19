 unit GeomBox;

interface

    uses
        System.SysUtils, system.Math, system.Math.Vectors, system.Types,
        LinearAlgebraTypes,
        LinearRescalingMethods,
        GeometryTypes
        ;

    type
        TGeomBox = record
            var
                minPoint, maxPoint : TGeomPoint;
            //construction
                constructor create(const point1In, point2In : TGeomPoint); overload;
            //copy other
                procedure copyBox(const otherBoxIn : TGeomBox);
            //centre point
                function calculateCentreX() : double;
                function calculateCentreY() : double;
                function calculateCentreZ() : double;
                function getCentrePoint() : TGeomPoint;
                procedure setCentrePoint(const xIn, yIn, zIn : double); overload;
                procedure setCentrePoint(const xIn, yIn : double); overload;
                procedure setCentrePoint(const newCentrePointIn : TGeomPoint); overload;
                class procedure setCentrePoint( const newCentrePointIn  : TGeomPoint;
                                                var arrGeomPointsIn     : TArray<TGeomPoint> ); overload; static;
            //set boundaries
                procedure setXBounds(const xMinIn, xMaxIn : double);
                procedure setYBounds(const yMinIn, yMaxIn : double);
                procedure setZBounds(const zMinIn, zMaxIn : double);
                procedure setBounds(const   xMinIn, xMaxIn,
                                            yMinIn, yMaxIn,
                                            zMinIn, zMaxIn  : double);
            //set points
                procedure setPoints(const point1In, point2In : TGeomPoint);
            //shift box
                procedure shiftX(const deltaXIn : double);
                procedure shiftY(const deltaYIn : double);
                procedure shiftZ(const deltaZIn : double);
                procedure shiftBox(const deltaXIn, deltaYIn : double); overload;
                procedure shiftBox(const deltaXIn, deltaYIn, deltaZIn : double); overload;
            //comparison
                function pointIsWithin(const pointIn : TGeomPoint) : boolean;
            //calculate dimensions
                function calculateXDimension() : double;
                function calculateYDimension() : double;
                function calculateZDimension() : double;
            //set dimensions
                procedure setXDimension(const newXLengthIn : double);
                procedure setYDimension(const newYLengthIn : double);
                procedure setZDimension(const newZLengthIn : double);
                procedure setDimensions(const newXLengthIn, newYLengthIn : double); overload;
                procedure setDimensions(const newXLengthIn, newYLengthIn, newZLengthIn : double); overload;
            //scale box
                procedure scaleBox( const scaleFactorIn     : double;
                                    const scaleAboutPointIn : TGeomPoint ); overload;
                procedure scaleBox(const scaleFactorIn : double); overload;
            //min and max properties
                property xMin : double read minPoint.x;
                property yMin : double read minPoint.y;
                property zMin : double read minPoint.z;
                property xMax : double read maxPoint.x;
                property yMax : double read maxPoint.y;
                property zMax : double read maxPoint.z;
            //new box with min point at (0, 0, 0) and x, y, x dimensions
                class function newBox(const xDimensionIn, yDimensionIn : double) : TGeomBox; overload; static;
                class function newBox(const xDimensionIn, yDimensionIn, zDimensionIn : double) : TGeomBox; overload; static;
            //determine bounding box from an array of points
                class function determineBoundingBox(const arrGeomPointsIn : TArray<TGeomPoint>) : TGeomBox; overload; static;
            //determine bounding box from an array of boxes
                class function determineBoundingBox(const arrGeomBoxesIn : TArray<TGeomBox>) : TGeomBox; overload; static;
        end;

implementation

    //construction
        constructor TGeomBox.create(const point1In, point2In : TGeomPoint);
            begin
                self.setPoints( point1In, point2In );
            end;

    //copy other
        procedure TGeomBox.copyBox(const otherBoxIn : TGeomBox);
            begin
                self.setPoints( otherBoxIn.minPoint, otherBoxIn.maxPoint );
            end;

    //centre point
        function TGeomBox.calculateCentreX() : double;
            begin
                result := (minPoint.x + maxPoint.x) / 2;
            end;

        function TGeomBox.calculateCentreY() : double;
            begin
                result := (minPoint.y + maxPoint.y) / 2;
            end;

        function TGeomBox.calculateCentreZ() : double;
            begin
                result := (minPoint.z + maxPoint.z) / 2;
            end;

        function TGeomBox.getCentrePoint() : TGeomPoint;
            begin
                result := TGeomPoint.create(
                                                calculateCentreX(),
                                                calculateCentreY(),
                                                calculateCentreZ()
                                           );
            end;

        procedure TGeomBox.setCentrePoint(const xIn, yIn, zIn : double);
            begin
                //shift to new position
                    shiftBox(
                                xIn - calculateCentreX(),   //required x-shift
                                yIn - calculateCentreY(),   //required y-shift
                                zIn - calculateCentreZ()    //required z-shift
                            );
            end;

        procedure TGeomBox.setCentrePoint(const xIn, yIn : double);
            begin
                setCentrePoint(xIn, yIn, 0);
            end;

        procedure TGeomBox.setCentrePoint(const newCentrePointIn : TGeomPoint);
            begin
                setCentrePoint(
                                    newCentrePointIn.x,
                                    newCentrePointIn.y,
                                    newCentrePointIn.z
                              );
            end;

        class procedure TGeomBox.setCentrePoint(const newCentrePointIn  : TGeomPoint;
                                                var arrGeomPointsIn     : TArray<TGeomPoint>);
            var
                i                   : integer;
                currentCentrePoint  : TGeomPoint;
                shiftVector         : TLAVector;
            begin
                //calculate the centre point of the point array
                    currentCentrePoint := TGeomPoint.calculateCentrePoint( arrGeomPointsIn );

                //calculate how far the points array must shift
                    shiftVector := TGeomPoint.calculateVector( newCentrePointIn, currentCentrePoint );

                //loop through the array and shift each point
                    for i := 0 to (length(arrGeomPointsIn) - 1) do
                        arrGeomPointsIn[i].shiftPoint(
                                                        shiftVector[0],
                                                        shiftVector[1],
                                                        shiftVector[2]
                                                     );
            end;

    //set boundaries
        procedure TGeomBox.setXBounds(const xMinIn, xMaxIn : double);
            begin
                minPoint.x := xMinIn;
                maxPoint.x := xMaxIn;
            end;

        procedure TGeomBox.setYBounds(const yMinIn, yMaxIn : double);
            begin
                minPoint.y := yMinIn;
                maxPoint.y := yMaxIn;
            end;

        procedure TGeomBox.setZBounds(const zMinIn, zMaxIn : double);
            begin
                minPoint.z := zMinIn;
                maxPoint.z := zMaxIn;
            end;

        procedure TGeomBox.setBounds(const  xMinIn, xMaxIn,
                                            yMinIn, yMaxIn,
                                            zMinIn, zMaxIn  : double);
            begin
                minPoint.setPoint( xMinIn, yMinIn, zMinIn );
                maxPoint.setPoint( xMaxIn, yMaxIn, zMaxIn );
            end;

    //set points
        procedure TGeomBox.setPoints(const point1In, point2In : TGeomPoint);
            begin
                //min point
                    minPoint.x := min( point1In.x, point2In.x );
                    minPoint.y := min( point1In.y, point2In.y );
                    minPoint.z := min( point1In.z, point2In.z );
                //max point
                    maxPoint.x := max( point1In.x, point2In.x );
                    maxPoint.y := max( point1In.y, point2In.y );
                    maxPoint.z := max( point1In.z, point2In.z );
            end;

    //shift box
        procedure TGeomBox.shiftX(const deltaXIn : double);
            begin
                minPoint.shiftX( deltaXIn );
                maxPoint.shiftX( deltaXIn );
            end;

        procedure TGeomBox.shiftY(const deltaYIn : double);
            begin
                minPoint.shiftY( deltaYIn );
                maxPoint.shiftY( deltaYIn );
            end;

        procedure TGeomBox.shiftZ(const deltaZIn : double);
            begin
                minPoint.shiftZ( deltaZIn );
                maxPoint.shiftZ( deltaZIn );
            end;

        procedure TGeomBox.shiftBox(const deltaXIn, deltaYIn : double);
            begin
                minPoint.shiftPoint( deltaXIn, deltaYIn );
                maxPoint.shiftPoint( deltaXIn, deltaYIn );
            end;

        procedure TGeomBox.shiftBox(const deltaXIn, deltaYIn, deltaZIn : double);
            begin
                minPoint.shiftPoint( deltaXIn, deltaYIn, deltaZIn );
                maxPoint.shiftPoint( deltaXIn, deltaYIn, deltaZIn );
            end;

    //comparison
        function TGeomBox.pointIsWithin(const pointIn: TGeomPoint): boolean;
            var
                greaterThanMinPoint, lessThanMaxPoint : boolean;
            begin
                greaterThanMinPoint := pointIn.greaterThanOrEqual(minPoint);

                lessThanMaxPoint := pointIn.lessThanOrEqual(maxPoint);

                result := (greaterThanMinPoint AND lessThanMaxPoint);
            end;

    //calculate dimensions
        function TGeomBox.calculateXDimension() : double;
            begin
                result := maxPoint.x - minPoint.x;
            end;

        function TGeomBox.calculateYDimension() : double;
            begin
                result := maxPoint.y - minPoint.y;
            end;

        function TGeomBox.calculateZDimension() : double;
            begin
                result := maxPoint.z - minPoint.z;
            end;

    //set dimensions
        procedure TGeomBox.setXDimension(const newXLengthIn : double);
            begin
                resizeLine( self.xMin,          self.xMax,
                            calculateCentreX(), newXLengthIn,
                            self.minPoint.x,    self.maxPoint.x );
            end;

        procedure TGeomBox.setYDimension(const newYLengthIn : double);
            begin
                resizeLine( self.yMin,          self.yMax,
                            calculateCentreY(), newYLengthIn,
                            self.minPoint.y,    self.maxPoint.y );
            end;

        procedure TGeomBox.setZDimension(const newZLengthIn : double);
            begin
                resizeLine( self.zMin,          self.zMax,
                            calculateCentreZ(), newZLengthIn,
                            self.minPoint.z,    self.maxPoint.z );
            end;

        procedure TGeomBox.setDimensions(const newXLengthIn, newYLengthIn : double);
            begin
                setXDimension( newXLengthIn );
                setYDimension( newYLengthIn );
            end;

        procedure TGeomBox.setDimensions(const newXLengthIn, newYLengthIn, newZLengthIn : double);
            begin
                setXDimension( newXLengthIn );
                setYDimension( newYLengthIn );
                setZDimension( newZLengthIn );
            end;

    //scale box
        procedure TGeomBox.scaleBox(const scaleFactorIn     : double;
                                    const scaleAboutPointIn : TGeomPoint);
            begin
                minPoint.scalePoint( scaleFactorIn, scaleAboutPointIn );
                maxPoint.scalePoint( scaleFactorIn, scaleAboutPointIn );
            end;

        procedure TGeomBox.scaleBox(const scaleFactorIn : double);
            begin
                self.scaleBox( scaleFactorIn, self.getCentrePoint() );
            end;

    //new box with min point at (0, 0, 0) and x, y, x dimensions
        class function TGeomBox.newBox(const xDimensionIn, yDimensionIn : double) : TGeomBox;
            begin
                result := newBox(xDimensionIn, yDimensionIn, 0);
            end;

        class function TGeomBox.newBox(const xDimensionIn, yDimensionIn, zDimensionIn : double) : TGeomBox;
            var
                localMinPoint, localMaxPoint : TGeomPoint;
            begin
                localMinPoint := TGeomPoint.create(0, 0, 0);
                localMaxPoint := TGeomPoint.create(xDimensionIn, yDimensionIn, zDimensionIn);

                result := TGeomBox.create( localMinPoint, localMaxPoint );
            end;

    //determine bounding box from an array of points
        class function TGeomBox.determineBoundingBox(const arrGeomPointsIn : TArray<TGeomPoint>) : TGeomBox;
            var
                i                               : integer;
                localMinPoint, localMaxPoint    : TGeomPoint;
                boundingBoxOut                  : TGeomBox;
            begin
                localMinPoint.copyPoint( arrGeomPointsIn[0] );
                localMaxPoint.copyPoint( arrGeomPointsIn[0] );

                for i := 1 to (length(arrGeomPointsIn) - 1) do
                    begin
                        //look for min x, y, z
                            localMinPoint.x := min( localMinPoint.x, arrGeomPointsIn[i].x );
                            localMinPoint.y := min( localMinPoint.y, arrGeomPointsIn[i].y );
                            localMinPoint.z := min( localMinPoint.z, arrGeomPointsIn[i].z );

                        //look for max x, y, z
                            localMaxPoint.x := max( localMaxPoint.x, arrGeomPointsIn[i].x );
                            localMaxPoint.y := max( localMaxPoint.y, arrGeomPointsIn[i].y );
                            localMaxPoint.z := max( localMaxPoint.z, arrGeomPointsIn[i].z );
                    end;

                boundingBoxOut := TGeomBox.create(localMinPoint, localMaxPoint);

                result := boundingBoxOut;
            end;

    //determine bounding box from an array of boxes
        class function TGeomBox.determineBoundingBox(const arrGeomBoxesIn : TArray<TGeomBox>) : TGeomBox;
            var
                i, arrLen                       : integer;
                localMinPoint, localMaxPoint    : TGeomPoint;
                boundingBoxOut                  : TGeomBox;
            begin
                arrLen := length(arrGeomBoxesIn);

                if ( arrLen < 1 ) then
                    exit( boundingBoxOut );

                localMinPoint.copyPoint( arrGeomBoxesIn[0].minPoint );
                localMaxPoint.copyPoint( arrGeomBoxesIn[0].maxPoint );

                for i := 1 to ( arrLen - 1 ) do
                    begin
                        //look for min x, y, z
                            localMinPoint.x := min( localMinPoint.x, arrGeomBoxesIn[i].xMin );
                            localMinPoint.y := min( localMinPoint.y, arrGeomBoxesIn[i].yMin );
                            localMinPoint.z := min( localMinPoint.z, arrGeomBoxesIn[i].zMin );

                        //look for max x, y, z
                            localMaxPoint.x := max( localMaxPoint.x, arrGeomBoxesIn[i].xMax );
                            localMaxPoint.y := max( localMaxPoint.y, arrGeomBoxesIn[i].yMax );
                            localMaxPoint.z := max( localMaxPoint.z, arrGeomBoxesIn[i].zMax );
                    end;

                boundingBoxOut := TGeomBox.create( localMinPoint, localMaxPoint );

                result := boundingBoxOut;
            end;

end.
