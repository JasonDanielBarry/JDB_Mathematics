unit GeometryTypes;

interface

     uses
        System.SysUtils, system.Math, system.Types,
        LinearAlgebraTypes,
        LinearRescalingMethods,
        MatrixMethods, VectorMethods
        ;

     type
        {$SCOPEDENUMS ON}
            EAxis = (eaX = 0, eaY = 1, eaZ = 2);
            EBoundaryRelation = (brInside = 0, brOn = 1, brOutside = 2);
        {$SCOPEDENUMS OFF}

        TGeomPoint = record
            private
                //rotation
                    procedure rotatePoint2D(const rotationMatrixIn          : TLAMatrix;
                                            const rotationReferencePointIn  : TGeomPoint);
                    procedure rotatePoint3D(const rotationMatrixIn          : TLAMatrix;
                                            const rotationReferencePointIn  : TGeomPoint);
                //to vector
                    function toVector() : TLAVector;
            public
                var
                    x, y, z : double;
                //constructors
                    constructor create(const xIn, yIn, zIn : double); overload;
                    constructor create(const xIn, yIn : double); overload;
                    constructor create(const PointFIn : TPointF); overload;
                    constructor create(const PointIn : TPoint); overload;
                //comparison
                    function greaterThan(const pointIn : TGeomPoint) : boolean;
                    function greaterThanOrEqual(const pointIn : TGeomPoint) : boolean;
                    function isEqual(const pointIn : TGeomPoint) : boolean;
                    function lessThan(const pointIn : TGeomPoint) : boolean;
                    function lessThanOrEqual(const pointIn : TGeomPoint) : boolean;
                //set point
                    procedure setPoint(const xIn, yIn, zIn : double); overload;
                    procedure setPoint(const xIn, yIn : double); overload;
                    procedure setPoint(const PointFIn : TPointF); overload;
                    procedure setPoint(const PointIn : TPoint); overload;
                //copy
                    procedure copyPoint(const otherGeomPointIn : TGeomPoint);
                    class procedure copyPoints(const arrPointsIn : TArray<TGeomPoint>; out arrPointsOut : TArray<TGeomPoint>); static;
                //shift point
                    procedure shiftX(const deltaXIn : double);
                    procedure shiftY(const deltaYIn : double);
                    procedure shiftZ(const deltaZIn : double);
                    procedure shiftPoint(const deltaXIn, deltaYIn : double); overload;
                    procedure shiftPoint(const deltaXIn, deltaYIn, deltaZIn : double); overload;
                //scale point distance from other point
                    procedure scalePoint(   const scaleFactorIn     : double;
                                            const referencePointIn  : TGeomPoint    );
                    class procedure scalePoints(const scaleFactorIn     : double;
                                                const referencePointIn  : TGeomPoint;
                                                var arrGeomPointsIn     : TArray<TGeomPoint>); overload; static;
                    class procedure scalePoints(const scaleFactorIn     : double;
                                                var arrGeomPointsIn     : TArray<TGeomPoint>); overload; static;
                //rotation
                    procedure rotatePoint(  const rotationAngleIn           : double;
                                            const rotationReferencePointIn  : TGeomPoint    ); overload;
                    procedure rotatePoint(  const alphaIn, betaIn, gammaIn  : double;
                                            const rotationReferencePointIn  : TGeomPoint    ); overload;
                    class procedure rotateArrPoints(const rotationAngleIn           : double;
                                                    const rotationReferencePointIn  : TGeomPoint;
                                                    var arrGeomPointsIn             : TArray<TGeomPoint>); overload; static;
                    class procedure rotateArrPoints(const alphaIn, betaIn, gammaIn  : double;
                                                    const rotationReferencePointIn  : TGeomPoint;
                                                    var arrGeomPointsIn             : TArray<TGeomPoint>); overload; static;
                    class procedure rotateArrPoints(const rotationAngleIn           : double;
                                                    var arrGeomPointsIn             : TArray<TGeomPoint>); overload; static;
                    class procedure rotateArrPoints(const alphaIn, betaIn, gammaIn  : double;
                                                    var arrGeomPointsIn             : TArray<TGeomPoint>); overload; static;
                //calculate vector from tail to head
                    class function calculateVector(const headPointIn, tailPointIn : TGeomPoint) : TLAVector; static;
                //calculate centre point
                    class function calculateCentrePoint(const arrPointsIn : TArray<TGeomPoint>) : TGeomPoint; static;
                //calculate distance
                    class function calculateDistanceBetweenPoints(const point1In, point2In : TGeomPoint) : double; static;
                    function calculateDistanceToPoint(const otherPointIn : TGeomPoint) : double;
        end;

        TGeomLineIntersectionData = record
            intersectionExists  : boolean;
            relativeToBound     : EBoundaryRelation;
            point               : TGeomPoint;
        end;

implementation

    //private
        //rotation
            procedure TGeomPoint.rotatePoint2D( const rotationMatrixIn          : TLAMatrix;
                                                const rotationReferencePointIn  : TGeomPoint );
                var
                    pointVector, rotatedVector : TLAVector;
                begin
                    SetLength( pointVector, 2 );

                    //calculate the vector from the reference point to the point to be rotated
                        pointVector[0] := self.x - rotationReferencePointIn.x;
                        pointVector[1] := self.y - rotationReferencePointIn.y;

                    //calculate the rotated vector
                        rotatedVector := matrixMultiplication( rotationMatrixIn, pointVector );

                    //set point to new position
                        setPoint(
                                    rotatedVector[0] + rotationReferencePointIn.x,
                                    rotatedVector[1] + rotationReferencePointIn.y
                                );
                end;

            procedure TGeomPoint.rotatePoint3D( const rotationMatrixIn          : TLAMatrix;
                                                const rotationReferencePointIn  : TGeomPoint );
                var
                    pointVector, rotatedVector : TLAVector;
                begin
                    SetLength( pointVector, 3 );

                    //calculate the vector from the reference point to the point to be rotated
                        pointVector[0] := self.x - rotationReferencePointIn.x;
                        pointVector[1] := self.y - rotationReferencePointIn.y;
                        pointVector[2] := self.z - rotationReferencePointIn.z;

                    //calculate the rotated vector
                        rotatedVector := matrixMultiplication( rotationMatrixIn, pointVector );

                    //set point to new position
                        setPoint(
                                    rotatedVector[0] + rotationReferencePointIn.x,
                                    rotatedVector[1] + rotationReferencePointIn.y,
                                    rotatedVector[2] + rotationReferencePointIn.z
                                );
                end;

        //to vector
            function TGeomPoint.toVector() : TLAVector;
                var
                    vectorOut : TLAVector;
                begin
                    SetLength( vectorOut, 3 );

                    vectorOut[0] := self.x;
                    vectorOut[1] := self.y;
                    vectorOut[2] := self.z;

                    result := vectorOut;
                end;

    //public
        //constructors
            constructor TGeomPoint.create(const xIn, yIn, zIn : double);
                begin
                    setPoint( xIn, yIn, zIn );
                end;

            constructor TGeomPoint.create(const xIn, yIn : double);
                begin
                    setPoint( xIn, yIn );
                end;

            constructor TGeomPoint.create(const PointFIn : TPointF);
                begin
                    setPoint( PointFIn );
                end;

            constructor TGeomPoint.create(const PointIn : TPoint);
                begin
                    setPoint( PointIn )
                end;

        //comparison
            function TGeomPoint.greaterThan(const pointIn : TGeomPoint) : boolean;
                begin
                    result :=       (pointIn.x < self.x)
                                AND (pointIn.y < self.y)
                                AND (pointIn.z < self.z)
                end;

            function TGeomPoint.greaterThanOrEqual(const pointIn: TGeomPoint): Boolean;
                begin
                    result := greaterThan( pointIn ) OR isEqual( pointIn );
                end;

            function TGeomPoint.isEqual(const pointIn : TGeomPoint) : boolean;
                const
                    EQUALITY_TOLERANCE : double = 1e-6;
                begin
                    result :=       SameValue( pointIn.x, self.x, EQUALITY_TOLERANCE )
                                AND SameValue( pointIn.y, self.y, EQUALITY_TOLERANCE )
                                AND SameValue( pointIn.z, self.z, EQUALITY_TOLERANCE )
                end;

            function TGeomPoint.lessThan(const pointIn: TGeomPoint): boolean;
                begin
                    result :=       (self.x < pointIn.x)
                                AND (self.y < pointIn.y)
                                AND (self.z < pointIn.z)
                end;

            function TGeomPoint.lessThanOrEqual(const pointIn: TGeomPoint): Boolean;
                begin
                    result := lessThan( pointIn ) OR isEqual( pointIn );
                end;

        //set point
            procedure TGeomPoint.setPoint(const xIn, yIn, zIn : double);
                begin
                    x := xIn;
                    y := yIn;
                    z := zIn;
                end;

            procedure TGeomPoint.setPoint(const xIn, yIn : double);
                begin
                    setPoint( xIn, yIn, 0 );
                end;

            procedure TGeomPoint.setPoint(const PointFIn : TPointF);
                begin
                    setPoint( PointFIn.X, PointFIn.Y );
                end;

            procedure TGeomPoint.setPoint(const PointIn : TPoint);
                begin
                    setPoint( pointIn.X, PointIn.Y );
                end;

        //copy
            procedure TGeomPoint.copyPoint(const otherGeomPointIn : TGeomPoint);
                begin
                    setPoint(
                                otherGeomPointIn.x,
                                otherGeomPointIn.y,
                                otherGeomPointIn.z
                            );
                end;

            class procedure TGeomPoint.copyPoints(const arrPointsIn : TArray<TGeomPoint>; out arrPointsOut : TArray<TGeomPoint>);
                var
                    i, arrLen : integer;
                begin
                    arrLen := length( arrPointsIn );

                    SetLength( arrPointsOut, arrLen );

                    for i := 0 to ( arrLen - 1 ) do
                        arrPointsOut[i].copyPoint( arrPointsIn[i] );
                end;

        //shift point
            procedure TGeomPoint.shiftX(const deltaXIn : double);
                begin
                    self.x := self.x + deltaXIn;
                end;

            procedure TGeomPoint.shiftY(const deltaYIn : double);
                begin
                    self.y := self.y + deltaYIn;
                end;

            procedure TGeomPoint.shiftZ(const deltaZIn : double);
                begin
                    self.z := self.z + deltaZIn;
                end;

            procedure TGeomPoint.shiftPoint(const deltaXIn, deltaYIn : double);
                begin
                    shiftX( deltaXIn );
                    shiftY( deltaYIn );
                end;

            procedure TGeomPoint.shiftPoint(const deltaXIn, deltaYIn, deltaZIn : double);
                begin
                    shiftX( deltaXIn );
                    shiftY( deltaYIn );
                    shiftZ( deltaZIn );
                end;

        //scale point distance from other point
            procedure TGeomPoint.scalePoint(const scaleFactorIn     : double;
                                            const referencePointIn  : TGeomPoint);
                begin
                    //scale the x value
                        scaleLinear(referencePointIn.x, self.x,
                                    scaleFactorIn,      self.x  );

                    //scale the y value
                        scaleLinear(referencePointIn.y, self.y,
                                    scaleFactorIn,      self.y  );

                    //scale the z value
                        scaleLinear(referencePointIn.z, self.z,
                                    scaleFactorIn,      self.z  );
                end;

            class procedure TGeomPoint.scalePoints( const scaleFactorIn     : double;
                                                    const referencePointIn  : TGeomPoint;
                                                    var arrGeomPointsIn     : TArray<TGeomPoint> );
                var
                    i : integer;
                begin
                    for i := 0 to ( length( arrGeomPointsIn ) - 1 ) do
                        arrGeomPointsIn[i].scalePoint( scaleFactorIn, referencePointIn );
                end;

            class procedure TGeomPoint.scalePoints( const scaleFactorIn     : double;
                                                    var arrGeomPointsIn     : TArray<TGeomPoint> );
                var
                    groupCentrePoint : TGeomPoint;
                begin
                    groupCentrePoint := calculateCentrePoint( arrGeomPointsIn );

                    scalePoints( scaleFactorIn, groupCentrePoint, arrGeomPointsIn );
                end;

        //rotation
            procedure TGeomPoint.rotatePoint(   const rotationAngleIn           : double;
                                                const rotationReferencePointIn  : TGeomPoint    );
                var
                    localRotationMatrix : TLAMatrix;
                begin
                    localRotationMatrix := rotationMatrix2D( rotationAngleIn );

                    rotatePoint2D( localRotationMatrix, rotationReferencePointIn );
                end;

            procedure TGeomPoint.rotatePoint(   const alphaIn, betaIn, gammaIn  : double;
                                                const rotationReferencePointIn  : TGeomPoint    );
                var
                    localRotationMatrix : TLAMatrix;
                begin
                    localRotationMatrix := rotationMatrix3D( alphaIn, betaIn, gammaIn );

                    rotatePoint3D( localRotationMatrix, rotationReferencePointIn );
                end;

            class procedure TGeomPoint.rotateArrPoints( const rotationAngleIn           : double;
                                                        const rotationReferencePointIn  : TGeomPoint;
                                                        var arrGeomPointsIn             : TArray<TGeomPoint> );
                var
                    i               : integer;
                    rotationMatrix  : TLAMatrix;
                begin
                    rotationMatrix := rotationMatrix2D( rotationAngleIn );

                    for i := 0 to (length(arrGeomPointsIn) - 1) do
                        arrGeomPointsIn[i].rotatePoint2D( rotationMatrix, rotationReferencePointIn );
                end;

            class procedure TGeomPoint.rotateArrPoints( const alphaIn, betaIn, gammaIn  : double;
                                                        const rotationReferencePointIn  : TGeomPoint;
                                                        var arrGeomPointsIn             : TArray<TGeomPoint> );
                var
                    i               : integer;
                    rotationMatrix  : TLAMatrix;
                begin
                    rotationMatrix := rotationMatrix3D( alphaIn, betaIn, gammaIn );

                    for i := 0 to (length(arrGeomPointsIn) - 1) do
                        arrGeomPointsIn[i].rotatePoint3D( rotationMatrix, rotationReferencePointIn );
                end;

            class procedure TGeomPoint.rotateArrPoints( const rotationAngleIn           : double;
                                                        var arrGeomPointsIn             : TArray<TGeomPoint> );
                var
                    groupCentrePoint : TGeomPoint;
                begin
                    groupCentrePoint := calculateCentrePoint( arrGeomPointsIn );

                    rotateArrPoints(    rotationAngleIn,
                                        groupCentrePoint,
                                        arrGeomPointsIn     );
                end;

            class procedure TGeomPoint.rotateArrPoints( const alphaIn, betaIn, gammaIn  : double;
                                                        var arrGeomPointsIn             : TArray<TGeomPoint> );
                var
                    groupCentrePoint : TGeomPoint;
                begin
                    groupCentrePoint := calculateCentrePoint( arrGeomPointsIn );

                    rotateArrPoints(    alphaIn, betaIn, gammaIn,
                                        groupCentrePoint,
                                        arrGeomPointsIn             );
                end;

        //calculate vector from tail to head
            class function TGeomPoint.calculateVector(const headPointIn, tailPointIn : TGeomPoint) : TLAVector;
                var
                    vectorHead, vectorTail : TLAVector;
                begin
                    vectorHead := headPointIn.toVector();
                    vectorTail := tailPointIn.toVector();

                    result := vectorSubtraction( vectorHead, vectorTail );
                end;

        //calculate centre point
            class function TGeomPoint.calculateCentrePoint(const arrPointsIn : TArray<TGeomPoint>) : TGeomPoint;
                var
                    i, pointCount                                           : integer;
                    centroidX,          centroidY,          centroidZ,
                    sumPointMomentX,    sumPointMomentY,    sumPointMomentZ : double;
                begin
                    pointCount := length( arrPointsIn );

                    sumPointMomentX := 0;
                    sumPointMomentY := 0;
                    sumPointMomentZ := 0;

                    for i := 0 to (pointCount - 1) do
                        begin
                            sumPointMomentX := sumPointMomentX + arrPointsIn[i].x;
                            sumPointMomentY := sumPointMomentY + arrPointsIn[i].y;
                            sumPointMomentZ := sumPointMomentZ + arrPointsIn[i].z;
                        end;

                    centroidX := sumPointMomentX / pointCount;
                    centroidY := sumPointMomentY / pointCount;
                    centroidZ := sumPointMomentZ / pointCount;

                    result := TGeomPoint.create( centroidX, centroidY, centroidZ );
                end;

        //calculate distance
            class function TGeomPoint.calculateDistanceBetweenPoints(const point1In, point2In : TGeomPoint) : double;
                begin
                    result := norm( [
                                        point1In.x - point2In.x,
                                        point1In.y - point2In.y,
                                        point1In.z - point2In.z
                                    ] );
                end;

            function TGeomPoint.calculateDistanceToPoint(const otherPointIn : TGeomPoint) : double;
                begin
                    result := calculateDistanceBetweenPoints( self, otherPointIn );
                end;

end.
