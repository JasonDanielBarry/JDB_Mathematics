unit TEST_GeomLineClass;

interface

    uses
        system.SysUtils,
        DUnitX.TestFramework;

    type
      [TestFixture]
      TTestGeomLineClass = class
      public
        [Test]
        procedure TestLineIntersection();
      end;

implementation

    uses
        GeometryTypes, GeomLineClass;

    procedure TTestGeomLineClass.TestLineIntersection();
        var
            line1, line2            : TGeomLine;
            lineIntersectionData    : TGeomLineIntersectionData;
        begin
            //test 1:
                //(0, 0) - (1, 1)
                //(0, 1) - (1, 0)
                //IP = (0.5, 0.5)
                    line1 := TGeomLine.create(TGeomPoint.create(0, 0), TGeomPoint.create(1, 1));
                    line2 := TGeomLine.create(TGeomPoint.create(0, 1), TGeomPoint.create(1, 0));

                    lineIntersectionData := line1.calculateLineIntersection(line2);
                    FreeAndNil(line1);

                    assert.IsTrue(lineIntersectionData.point.isEqual( TGeomPoint.create(0.5, 0.5, 0) ));

            //test 2:
                //(-1, 0) - (1, 0)
                //(0, -1) - (0, 1)
                //IP = (0, 0)
                    line1 := TGeomLine.create(TGeomPoint.create(-1, 0), TGeomPoint.create(1, 0));
                    line2 := TGeomLine.create(TGeomPoint.create(0, -1), TGeomPoint.create(0, 1));

                    lineIntersectionData := line1.calculateLineIntersection(line2);
                    FreeAndNil(line1);

                    assert.IsTrue(lineIntersectionData.point.isEqual( TGeomPoint.create(0, 0) ));

            //test 3: parallel lines
                //(0, 0) - (1, 0)
                //(0, 1) - (1, 1)
                //IP = False
                    line1 := TGeomLine.create(TGeomPoint.create(0, 0), TGeomPoint.create(1, 0));
                    line2 := TGeomLine.create(TGeomPoint.create(0, 1), TGeomPoint.create(1, 1));

                    lineIntersectionData := line1.calculateLineIntersection(line2);
                    FreeAndNil(line1);

                    assert.IsTrue(lineIntersectionData.intersectionExists = False);

            //test 4: parallel lines
                //(0, 0) - (0, 1)
                //(1, 0) - (1, 1)
                //IP = False
                    line1 := TGeomLine.create(TGeomPoint.create(0, 0), TGeomPoint.create(1, 0));
                    line2 := TGeomLine.create(TGeomPoint.create(0, 1), TGeomPoint.create(1, 1));

                    lineIntersectionData := line1.calculateLineIntersection(line2);
                    FreeAndNil(line1);

                    assert.IsTrue(lineIntersectionData.intersectionExists = False);

            //test 5:
                //(0, 10) - (5, 7.5)
                //(6, 0 ) - (11, 6 )
                //IP = (10.11764706, 4.941176471)
                    line1 := TGeomLine.create(TGeomPoint.create(0, 10), TGeomPoint.create(5 , 7.5));
                    line2 := TGeomLine.create(TGeomPoint.create(6, 0 ), TGeomPoint.create(11, 6  ));

                    lineIntersectionData := line1.calculateLineIntersection(line2);
                    FreeAndNil(line1);

                    assert.IsTrue(lineIntersectionData.point.isEqual( TGeomPoint.create(10.117647, 4.941176) ));
        end;

end.
