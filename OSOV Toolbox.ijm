
//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------
// latest release date: 07/12/2015
//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------

/**
	OpenSource Optical Vulnerability (OSOV) Tools

	DISCLAIMER:
	THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ?AS IS? AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

requires("1.50a");

	var filemenu = newMenu("OSOV Menu Tool", newArray(
		"Colour Slices",
		"Image Difference",
//	"Image Difference (batch)",
		"Clear Slices",
		"Save Slices",
		"Clear Slice",
		"Clear Outside",
		"Fill Outside",
		"Z Project",
		"Cumulative Z Project",
		"Remove Outliers",
		"Split Channels",
		"Merge Channels",
		"Remove Outliers",
		"Measure Stack",
		"Stack Contrast Adjustment",
		"Apply Mask To Stack", 
		"Crop and Align Images")
	);

	macro "OSOV Menu Tool - C000C010C020C030C040C050Df9C050D62C050D75C060D87C060D76C060D61C060Db8C060D63C060D74Da8Dc8C060D50De9C060D81C060De7C060D91Dc2C060D77Dd4Dd8C060De8C070D71D97Dd3C070D73D78C070D51D60De6C070D06D5aD69Db2C070D4bD86Dd5C070D3dD98Da7C070D64Da2C070D3cD72D82D83D84D85D92D93D94D95D96Da1Da3Da4Da5Da6Db3Db4Db5Db6Db7Dc3Dc4Dc5Dc6Dc7Dd6Dd7C070D2dC070Dd9C070C080D2cC080D15D19Dd2C080D88C080D18C080D24DafC080D33C080D2bC080D42D65C080De5C080D52C080D4cC080D17D41D68C080C090D2aD59C090D9fDb1Dc9C090D32D4aD5bC090D1aD3bC090D16D53D66C090D25D29D5eD6eDf8C090D26D27D28D34D35D36D37D38D39D3aD43D44D45D46D47D48D49D54D55D56D57D58D67DeaC090D6aC090DbeC090D07C090D23DdbC090D70D7eDcdC090D79DccC0a0D4eDb9C0a0DbdDdcC0a0D14C0a0D8eDaeC0a0D4dD8fC0a0D05Da9C0a0DebC0b0Dc1DfaC0b0D9eC0b0D5cD5dD99DdaC0b0D6bD6cD6dD7aD7bD7cD7dD89D8aD8bD8cD8dD9aD9bD9cD9dDaaDabDacDadDbaDbbDbcDcaDcbC0b0De4C0b0D1bD3eC0b0D80C0b0C0c0Df7C0c0D08C0c0D7fC0c0C0d0D2eC0d0Dd1C0d0D6fC0d0C0e0C0f0D5fC0f0"{
		menuCmd = getArgument();
		if (menuCmd!="-") {
			if (menuCmd=="Colour Slices") { run("OSOV Colour Slices"); }
			else if (menuCmd=="Image Difference") { run("OSOV Image Difference"); }
			else if (menuCmd=="Image Difference (batch)") { run("OSOV Batch Image Difference");}
			else if (menuCmd=="Clear Slices") { run("OSOV Clear Slices"); }
			else if (menuCmd=="Save Slices") { run("OSOV Save Slices"); }
			else if (menuCmd=="Measure Stack") { run("OSOV Measure Stack"); }
			else if (menuCmd=="Apply Mask To Stack") { run("OSOV Apply Mask To Stack"); }
			else if (menuCmd=="Stack Contrast Adjustment") { run("Stack Contrast Adjustment"); }
			else if (menuCmd=="Z Project") { run("Z Project...", "projection=[Max Intensity]"); }
			else if (menuCmd=="Cumulative Z Project") { run("OSOV Cumulative Z Project"); }
			else if (menuCmd=="Remove Outliers") { run("Remove Outliers..."); }
			else if (menuCmd=="Split Channels") { run("Split Channels"); }
			else if (menuCmd=="Merge Channels") { run("Merge Channels..."); }
			else if (menuCmd=="Clear Outside") { run("OSOV Clear Outside"); }
			else if (menuCmd=="Fill Outside") { run("OSOV Fill Outside"); }
			else if (menuCmd=="Clear Slice") { run("OSOV Clear Slice"); }
			else if (menuCmd=="Crop and Align Images") { run("OSOV Crop And Align Images"); }
		}
	}
