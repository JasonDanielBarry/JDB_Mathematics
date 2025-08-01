unit GeometryTypes;

interface

     uses
        System.SysUtils, system.Math, system.Types,
        LinearAlgebraTypes,
        LinearRescalingMethods,
        LAMatrixMethods, LAVectorMethods
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
                    constructor create(const xIn, yIn : double; const zIn : double = 0); overload;
                    constructor create(const PointFIn : TPointF); overload;
                    constructor create(const PointIn : TPoint); overload;
                    class function createPointArray(const arrXIn, arrYIn : TArray<double>; const arrZIn : TArray<double> = []) : TArray<TGeomPoint>; static;
                //comparison
                    function greaterThan(const pointIn : TGeomPoint) : boolean;
                    function greaterThanOrEqual(const pointIn : TGeomPoint) : boolean;
                    function isEqual(const pointIn : TGeomPoint) : boolean;
                    function lessThan(const pointIn : TGeomPoint) : boolean;
                    function lessThanOrEqual(const pointIn : TGeomPoint) : boolean;
                //set point
                    procedure setPoint(const xIn, yIn : double; const zIn : double = 0); overload;
                    procedure setPoint(const PointFIn : TPointF); overload;
                    procedure setPoint(const PointIn : TPoint); overload;
                //copy
                    procedure copyPoint(const otherGeomPointIn : TGeomPoint);
                    class procedure copyPoints(const arrPointsIn : TArray<TGeomPoint>; out arrPointsOut : TArray<TGeomPoint>); static;
                //shift point
                    procedure shiftX(const deltaXIn : double);
                    procedure shiftY(const deltaYIn : double);
                    procedure shiftZ(const deltaZIn : double);
                    procedure shiftPoint(const deltaXIn, deltaYIn : double; const deltaZIn : double = 0);
                    class procedure shiftArrPointsByVector( const   vectorStartPointIn,
                                                                    vectorEndPointIn    : TGeomPoint;
                                                            var arrGeomPointsIn         : TArray<TGeomPoint> ); static;
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
                    class function calculateVector(const startPointIn, endPointIn : TGeomPoint) : TLAVector; static;
                //calculate centre point
                    class function calculateCentroidPoint(const arrPointsIn : TArray<TGeomPoint>) : TGeomPoint; static;
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
            constructor TGeomPoint.create(const xIn, yIn : double; const zIn : double = 0);
                begin
                    setPoint( xIn, yIn, zIn );
                end;

            constructor TGeomPoint.create(const PointFIn : TPointF);
                begin
                    setPoint( PointFIn );
                end;

            constructor TGeomPoint.create(const PointIn : TPoint);
                begin
                    setPoint( PointIn )
                end;

            class function TGeomPoint.createPointArray(const arrXIn, arrYIn : TArray<double>; const arrZIn : TArray<double> = []) : TArray<TGeomPoint>;
                var
                    arraysAreSameSize,
                    arrZIsNeeded            : boolean;
                    i, arrLen, arrZ_Size    : integer;
                    x, y, z                 : double;
                    arrGeomPointsOut        : TArray<TGeomPoint>;
                begin
                    //test if input arrays are correct sizes
                        arraysAreSameSize := vectorsAreSameSize( arrXIn, arrYIn );

                        if NOT( arraysAreSameSize ) then
                            exit();

                    //check the z array size
                        arrZ_Size := length( arrZIn );

                        if ( 0 < arrZ_Size ) then
                            begin
                                arraysAreSameSize := vectorsAreSameSize( arrXIn, arrZIn );

                                if NOT( arraysAreSameSize ) then
                                    exit();

                                arrZIsNeeded := True;
                            end
                        else
                            arrZIsNeeded := False;

                    //loop through arrays and populate point array
                        arrLen := length( arrXIn );

                        SetLength( arrGeomPointsOut, arrLen );

                        for i := 0 to ( arrLen - 1 ) do
                            begin
                                x := arrXIn[i];
                                y := arrYIn[i];

                                if ( arrZIsNeeded ) then
                                    z := arrZIn[i]
                                else
                                    z := 0;

                                arrGeomPointsOut[i].setPoint( x, y, z );
                            end;

                    result := arrGeomPointsOut;
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
            procedure TGeomPoint.setPoint(const xIn, yIn : double; const zIn : double = 0);
                begin
                    x := xIn;
                    y := yIn;
                    z := zIn;
                end;

            procedure TGeomPoint.setPoint(const PointFIn : TPointF);
                begin
                    setPoint( PointFIn.X, PointFIn.Y );
                end;

            procedure TGeomPoint.setPoint(const PointIn : TPoint);
                begin
                    setPoint( pointIn.X, PointIn.Y );
                end;

            class procedure TGeomPoint.shiftArrPointsByVector(  const   vectorStartPointIn,
                                                                        vectorEndPointIn    : TGeomPoint;
                                                                var arrGeomPointsIn         : TArray<TGeomPoint> );
                var
                    i           : integer;
                    shiftVector : TLAVector;
                begin
                    //calculate the vector by which the points array must shift
                        shiftVector := TGeomPoint.calculateVector( vectorStartPointIn, vectorEndPointIn );

                    //loop through the array and shift each point
                        for i := 0 to (length(arrGeomPointsIn) - 1) do
                            arrGeomPointsIn[i].shiftPoint(
                                                            shiftVector[0],
                                                            shiftVector[1],
                                                            shiftVector[2]
                                                         );
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

            procedure TGeomPoint.shiftPoint(const deltaXIn, deltaYIn : double; const deltaZIn : double = 0);
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
                    groupCentrePoint := calculateCentroidPoint( arrGeomPointsIn );

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
                    groupCentrePoint := calculateCentroidPoint( arrGeomPointsIn );

                    rotateArrPoints(    rotationAngleIn,
                                        groupCentrePoint,
                                        arrGeomPointsIn     );
                end;

            class procedure TGeomPoint.rotateArrPoints( const alphaIn, betaIn, gammaIn  : double;
                                                        var arrGeomPointsIn             : TArray<TGeomPoint> );
                var
                    groupCentrePoint : TGeomPoint;
                begin
                    groupCentrePoint := calculateCentroidPoint( arrGeomPointsIn );

                    rotateArrPoints(    alphaIn, betaIn, gammaIn,
                                        groupCentrePoint,
                                        arrGeomPointsIn             );
                end;

        //calculate vector from tail to head
            class function TGeomPoint.calculateVector(const startPointIn, endPointIn : TGeomPoint) : TLAVector;
                var
                    vectorOut : TArray<double>;
                begin
                    SetLength( vectorOut, 3 );

                    vectorOut[0] := endPointIn.x - startPointIn.x;
                    vectorOut[1] := endPointIn.y - startPointIn.y;
                    vectorOut[2] := endPointIn.z - startPointIn.z;

                    result := vectorOut;
                end;

        //calculate centre point
            class function TGeomPoint.calculateCentroidPoint(const arrPointsIn : TArray<TGeomPoint>) : TGeomPoint;
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
                var
                    P1P2Vector : TLAVector;
                begin
                    P1P2Vector := calculateVector( point1In, point2In );

                    result := norm( P1P2Vector );
                end;

            function TGeomPoint.calculateDistanceToPoint(const otherPointIn : TGeomPoint) : double;
                begin
                    result := calculateDistanceBetweenPoints( self, otherPointIn );
                end;

end.
