// Simple runner for panodisplay to view example CORSIKA simulation
// Usage: root -l run_example.C
// To save PNGs (headless): root -l -b -q 'run_example.C(0,true,"example")'

#include "TCanvas.h"
#include "TCollection.h"
#include "TROOT.h"
#include "TString.h"
#include "iostream"

void run_example(int eventNumber = 0, bool savePng = false, const char* outputPrefix = "example") {
    std::cout << "Reading example.root" << std::endl;
    std::cout << "Displaying event " << eventNumber << std::endl;
    gROOT->LoadMacro("panodisplay.C");

    // Read the file and display event - check both possible locations
    const char* rootFile = "example.root";
    if (gSystem->AccessPathName(rootFile)) {
        // Check if it's in ../example/
        std::string altPath = "../example/example.root";
        if (!gSystem->AccessPathName(altPath.c_str())) {
            rootFile = altPath.c_str();
        }
    }

    readFile(rootFile);

    // Use batch mode when saving PNGs (no X11 required)
    gROOT->SetBatch(savePng ? kTRUE : kFALSE);

    panodisplay(eventNumber);

    if (savePng) {
        TIter next(gROOT->GetListOfCanvases());
        TCanvas* c = nullptr;
        while ((c = (TCanvas*)next())) {
            TString name = c->GetName();
            name.ReplaceAll(" ", "_");
            TString file;
            if (outputPrefix && outputPrefix[0] != '\0') {
                file.Form("%s_%s.png", outputPrefix, name.Data());
            } else {
                file.Form("%s.png", name.Data());
            }
            c->SaveAs(file);
        }
    }
}
