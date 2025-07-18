unit DrawingAxisConversionAspectRatioClass;

interface

    uses
        System.SysUtils, system.Math, system.Types,
        LinearRescalingMethods,
        GeometryTypes, GeomBox,
        DrawingAxisConversionPanningClass
        ;

    type
        TDrawingAxisAspectRatioConverter = class(TDrawingAxisPanningConverter)
            private
                //adjust the drawing region to assume the desired aspect ratio
                    procedure adjustDrawingRegionAspectRatio(const ratioIn : double);
            public
                //constructor
                    constructor create(); override;
                //destructor
                    destructor destroy(); override;
                //set the drawing region range/domain ratio
                    procedure setDrawingSpaceRatio(const ratioIn : double);
        end;

implementation

    //private
        //adjust the drawing region to assume the desired aspect ratio
            procedure TDrawingAxisAspectRatioConverter.adjustDrawingRegionAspectRatio(const ratioIn : double);
                var
                    drawRange, newDomain : double;
                begin
                    drawRange := drawingRegion.calculateYDimension();

                    //calculate new domain: D = R(r)(w/h)
                        newDomain := ratioIn * drawRange * ( canvasDimensions.Width / canvasDimensions.Height );

                    drawingRegion.setXDimension( newDomain );
                end;

    //public
        //constructor
            constructor TDrawingAxisAspectRatioConverter.create();
                begin
                    inherited create();
                end;

        //destructor
            destructor TDrawingAxisAspectRatioConverter.destroy();
                begin
                    inherited destroy();
                end;

        //set the drawing region range/domain ratio
            procedure TDrawingAxisAspectRatioConverter.setDrawingSpaceRatio(const ratioIn : double);
                var
                    currentZoomPercentage : double;
                begin
                    //catch current zoom percentage
                        currentZoomPercentage := calculateCurrentZoomPercentage();

                    //set the aspect ratio as desired
                        adjustDrawingRegionAspectRatio( ratioIn );

                    //set the correct zoom percentage
                        setZoom( currentZoomPercentage );
                end;


end.
