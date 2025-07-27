unit DrawingAxisConversionMouseControlClass;

interface

    uses
        system.SysUtils, system.math, system.Types,
        Winapi.Windows, winapi.Messages,
        DrawingAxisConversionAspectRatioClass,
        GeometryTypes, GeomBox
        ;

    type
        TDrawingAxisMouseControlConverter = class(TDrawingAxisAspectRatioConverter)
            private
                var
                    mouseControlIsActive,
                    mousePanningIsActive,
                    mustRedrawOnMouseMoveIsActive   : boolean;
                    currentMousePosition,
                    mousePanningOrigin              : TPoint;
                    regionPanningOrigin             : TGeomPoint;
                //modifiers
                    procedure setMousePositionLT(const newMousePositionIn : TPoint);
                //activate/deactivate mouse panning
                    procedure activateMousePanning();
                    procedure deactivateMousePanning();
                //panning with mouse
                    procedure panRegionWithMouse();
                //zooming relative to mouse
                    procedure zoomInRelativeToMouse();
                    procedure zoomOutRelativeToMouse();
                    procedure zoomRelativeToMouse(const messageIn : TMessage);
            public
                //constructor
                    constructor create(); override;
                //destructor
                    destructor destroy(); override;
                //accessors
                    property MouseControlActive : boolean read mouseControlIsActive;
                    property RedrawOnMouseMoveActive : boolean read mustRedrawOnMouseMoveIsActive;
                    function getMouseCoordinatesXY() : TGeomPoint;
                //activate/deactivate mouse control
                    procedure activateMouseControl();
                    procedure deactivateMouseControl();
                //activate/deactivate mouse point tracking
                    procedure setRedrawOnMouseMoveActive(const isActiveIn : boolean);
                //process windows messages
                    function windowsMessageRequiredRedraw(  const newMousePositionIn    : TPoint;
                                                            const messageIn             : Tmessage  ) : boolean;
        end;

implementation

    //private
        //modifiers
            procedure TDrawingAxisMouseControlConverter.setMousePositionLT(const newMousePositionIn : TPoint);
                begin
                    currentMousePosition := newMousePositionIn;
                end;

        //activate mouse panning
            procedure TDrawingAxisMouseControlConverter.activateMousePanning();
                begin
                    //this function must only
                        if NOT( mouseControlIsActive ) then
                            begin
                                deactivateMouseControl();
                                exit();
                            end;

                    //if mouse panning is already active then the function must exit so as not to override the panning origin points
                        if (mousePanningIsActive) then
                            exit();

                    mousePanningIsActive := True;

                    //origin points for panning region
                        mousePanningOrigin  := currentMousePosition;
                        regionPanningOrigin := drawingRegion.calculateCentrePoint();
                end;

            procedure TDrawingAxisMouseControlConverter.deactivateMousePanning();
                begin
                    mousePanningIsActive := False;
                end;

        //panning with mouse
            procedure TDrawingAxisMouseControlConverter.panRegionWithMouse();
                var
                    mouse_dL,           mouse_dT            : integer;
                    newRegionCentreX,   newRegionCentreY    : double;
                begin
                    if NOT( mousePanningIsActive ) then
                        exit();

                    //calculate how much the mouse moves from the point where the middle mouse button is pressed down
                        mouse_dL :=  currentMousePosition.X - mousePanningOrigin.X;
                        mouse_dT :=  currentMousePosition.Y - mousePanningOrigin.Y;

                    //calculate new region centre point
                    //the shift is subtracted because the region centre must move in the opposite direction to the mouse
                        newRegionCentreX := regionPanningOrigin.x - dL_To_dX( mouse_dL ); //mouseRegionShiftX = dL_To_dX( mouse_dL );
                        newRegionCentreY := regionPanningOrigin.y - dT_To_dY( mouse_dT ); //mouseRegionShiftY = dT_To_dY( mouse_dT );

                    //move region to new position
                        drawingRegion.setCentrePoint( newRegionCentreX, newRegionCentreY );
                end;

        //zooming relative to mouse
            procedure TDrawingAxisMouseControlConverter.zoomInRelativeToMouse();
                var
                    regionPoint : TGeomPoint;
                begin
                    regionPoint := LT_to_XY( currentMousePosition );

                    zoomIn( 20, regionPoint );
                end;

            procedure TDrawingAxisMouseControlConverter.zoomOutRelativeToMouse();
                var
                    regionPoint : TGeomPoint;
                begin
                    regionPoint := LT_to_XY( currentMousePosition );

                    zoomOut( 20, regionPoint );
                end;

            procedure TDrawingAxisMouseControlConverter.zoomRelativeToMouse(const messageIn : TMessage);
                begin
                    if (messageIn.WParam = 7864320) then
                        zoomInRelativeToMouse()
                    else
                        zoomOutRelativeToMouse();
                end;

    //public
        //constructor
            constructor TDrawingAxisMouseControlConverter.create();
                begin
                    inherited create();

                    deactivateMouseControl();
                end;

        //destructor
            destructor TDrawingAxisMouseControlConverter.destroy();
                begin
                    inherited destroy();
                end;

        //accessors
            function TDrawingAxisMouseControlConverter.getMouseCoordinatesXY() : TGeomPoint;
                begin
                    result := LT_to_XY( currentMousePosition );
                end;

        //activate/deactivate mouse control
            procedure TDrawingAxisMouseControlConverter.activateMouseControl();
                begin
                    mouseControlIsActive := True;
                end;

            procedure TDrawingAxisMouseControlConverter.deactivateMouseControl();
                begin
                    deactivateMousePanning();

                    mouseControlIsActive := False;
                end;

        //activate/deactivate mouse point tracking
            procedure TDrawingAxisMouseControlConverter.setRedrawOnMouseMoveActive(const isActiveIn : boolean);
                begin
                    mustRedrawOnMouseMoveIsActive := isActiveIn;
                end;

        //process windows messages
            function TDrawingAxisMouseControlConverter.windowsMessageRequiredRedraw(const newMousePositionIn    : TPoint;
                                                                                    const messageIn             : Tmessage) : boolean;
                begin
                    result := false;

                    //ensure the axis convertsion class is created before processing any messages
                        if (self = nil) then
                            exit( False );

                    //procedure must only run if mouse control is activated
                        if NOT( mouseControlIsActive ) then
                            exit( False );

                    case (messageIn.Msg) of
                        WM_MBUTTONDOWN:
                            activateMousePanning();

                        WM_MBUTTONUP:
                            deactivateMousePanning();

                        WM_MBUTTONDBLCLK:
                            begin
                                resetDrawingRegionToGeometryBoundary(); //has effect of zoom all
                                result := True;
                            end;

                        WM_MOUSEWHEEL:
                            begin
                                zoomRelativeToMouse( messageIn );
                                result := True;
                            end;

                        WM_MOUSEMOVE:
                            begin
                                setMousePositionLT( newMousePositionIn );

                                panRegionWithMouse();

                                result := mousePanningIsActive OR mustRedrawOnMouseMoveIsActive; // panRegionWithMouse only occurs if mouse panning is active
                            end;
                    end;
                end;

end.
