#ifndef __TRACKING
#define __TRACKING

#include <list>
#include <map>

#include "ofxCvContourFinder.h"

class BlobTracker 
{

public: 

	BlobTracker();

	//setup a event listener
	void setListener( ofCvBlobListener* _listener );

	//assigns IDs to each blob in the contourFinder
	void track(ofxCvContourFinder* newBlobs);
	int trackKnn(ofxCvContourFinder *newBlobs, ofxCvBlob *track, int k, double thresh);


private:
	
	std::vector<ofxCvBlob>	trackedBlobs; //tracked blobs
	int						IDCounter;	  //counter of last blob


protected:
  
    ofCvBlobListener* listener;

	//blob Events
    void doBlobOn( const ofxCvBlob& b );    
    void doBlobMoved( const ofxCvBlob& b );    
    void doBlobOff( const ofxCvBlob& b );    
    
};

#endif