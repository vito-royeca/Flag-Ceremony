#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MaplyActiveObject.h"
#import "MaplyAnimationTestTileSource.h"
#import "MaplyAnnotation.h"
#import "MaplyAtmosphere.h"
#import "MaplyBaseViewController.h"
#import "MaplyBillboard.h"
#import "MaplyBlankTileSource.h"
#import "MaplyComponentObject.h"
#import "MaplyCoordinate.h"
#import "MaplyCoordinateSystem.h"
#import "MaplyElevationDatabase.h"
#import "MaplyElevationSource.h"
#import "MaplyGDALRetileSource.h"
#import "MaplyGeomModel.h"
#import "MaplyIconManager.h"
#import "MaplyImageTile.h"
#import "MaplyLabel.h"
#import "MaplyLight.h"
#import "MaplyMarker.h"
#import "MaplyMatrix.h"
#import "MaplyMBTileSource.h"
#import "MaplyMoon.h"
#import "MaplyMultiplexTileSource.h"
#import "MaplyPagingElevationTestTileSource.h"
#import "MaplyPagingVectorTestTileSource.h"
#import "MaplyParticleSystem.h"
#import "MaplyQuadImageOfflineLayer.h"
#import "MaplyQuadImageTilesLayer.h"
#import "MaplyQuadPagingLayer.h"
#import "MaplyQuadTracker.h"
#import "MaplyRemoteTileElevationSource.h"
#import "MaplyRemoteTileSource.h"
#import "MaplyScreenLabel.h"
#import "MaplyScreenMarker.h"
#import "MaplyScreenObject.h"
#import "MaplyShader.h"
#import "MaplyShape.h"
#import "MaplySharedAttributes.h"
#import "MaplySphericalQuadEarthWithTexGroup.h"
#import "MaplyStarsModel.h"
#import "MaplySticker.h"
#import "MaplySun.h"
#import "MaplyTexture.h"
#import "MaplyTextureBuilder.h"
#import "MaplyTileSource.h"
#import "MaplyUpdateLayer.h"
#import "MaplyVectorObject.h"
#import "MaplyVertexAttribute.h"
#import "MaplyViewController.h"
#import "MaplyViewControllerLayer.h"
#import "MaplyViewTracker.h"
#import "MaplyWMSTileSource.h"
#import "NSData+Zlib.h"
#import "NSDictionary+StyleRules.h"
#import "WGCoordinate.h"
#import "WhirlyGlobeViewController.h"

FOUNDATION_EXPORT double WhirlyGlobeVersionNumber;
FOUNDATION_EXPORT const unsigned char WhirlyGlobeVersionString[];

