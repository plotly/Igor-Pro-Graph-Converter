#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <Readback ModifyStr>
#include <axis utilities>
#include <Extract Contours As Waves>
#include <Graph Utility Procs>
#include <Percentile and Box Plot>

// Requires Igor 6.1 or later for /FREE waves

// Returns 1 if the colortable ctab is in this list, meaning that it is
// discrete and should not be interpolated.  Users may add the wave name of
// their own discrete color tables to the list to avoid Plotly doing
// interpolation.
static Function DiscreteColorTable(ctab)
	string ctab

	string discreteList = "Grays16;Rainbow16;Geo32;LandAndSea8;Relief19;PastelsMap20;Bathymetry9;Fiddle;GreenMagenta16;EOSOrangeBlue11;EOSSpectral11;dBZ14;dBZ21;Web216;Classification"
	if(FindListItem(ctab, discreteList) > -1)
		return 1
	endif
	return 0
End

// Returns screen pixels size for markers given and igor marker size
//
// @todo: function not active
//
// Note:  * MARKERS, the formula is px=NearestOdd(2*IgorSize*ScreenResolution/72 - 1).
//        * NearestOdd(2*MrkSize*ScreenResolution/72 - 1)
//
// @see Txt2Px
static Function Mrk2Px(MrkSize)
	variable MrkSize
	return MrkSize
End

// Returns screen px size given an igor text point size
//
// For text, we have px=floor(pt*ScreenResolution/72) = floor(pt*4/3)
static Function Txt2Px(PtSize)
	variable PtSize
	return floor(ptSize * ScreenResolution / 72)
End

static Function NearestOdd(num)
	variable num
	return round((num + 1) / 2) * 2 - 1
End

// Returns the text cleaned of dangerous backslashes, and returns whatever data
// Plotly can use
static Function/T ProcessText(text, fontName, fontSize, OZ, [OZval])
	string text, &fontName
	variable &fontSize, &OZ, OZval

	variable closeQuote, index
	string xtra

	index = strsearch(text, "\F", 0)
	if(index > -1)
		closeQuote = strsearch(text, "'", index + 3)
		fontName = text[index + 3, closeQuote - 1]
		text = ReplaceString("\F'" + fontName + "'", text, "")
	else
		fontName = "default"
	endif

	index = strsearch(text, "\Z", 0)
	if(index > -1)
		fontSize = str2num(text[index + 2, index + 3])
		text = ReplaceString("\Z" + num2str(fontSize), text, "")
	else
		fontSize = 0
	endif

	index = strsearch(text, "\OZ", 0)
	if(index > -1)
		text = ReplaceString("\OZ", text, dub2str(OZval))
		OZ = 1
	else
		OZ = 0
	endif

	//Now remove unsupported escape codes, at least partially so that at least there is no error
	do
		index = strsearch(text, "\[", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 2]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\]", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 2]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	text = ReplaceString("\B", text, "", 1)
	text = ReplaceString("\JR", text, "", 1)
	text = ReplaceString("\JC", text, "", 1)
	text = ReplaceString("\JL", text, "", 1)
	text = ReplaceString("\M", text, "", 1)
	text = ReplaceString("\S", text, "", 1)
	text = ReplaceString("\t", text, "", 1)
	text = ReplaceString("\r", text, "", 1)
	text = ReplaceString("\n", text, "", 1)

	do
		index = strsearch(text, "\f", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 3]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\K", 0)
		if(index == -1)
			break
		endif
		closeQuote = strsearch(text, ")", index + 1)
		xtra = text[index, closeQuote]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\k", 0)
		if(index == -1)
			break
		endif
		closeQuote = strsearch(text, ")", index + 1)
		xtra = text[index, closeQuote]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\L", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 5]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(Text, "\$PICT$name=", 0)
		if(index == -1)
			break
		endif
		closeQuote = strsearch(Text, "$/PICT$", index, 1)
		xtra = text[index, closeQuote + 6]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\s", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 5]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\W", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 4]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\X", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 2]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\x", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 4]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = 1
		index = strsearch(text, "\Y", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 2]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\y", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 4]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\Zr", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 5]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\Z", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 3]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	// we already removed \OZ, which means something to us.
	do
		index = strsearch(text, "\O", 0)
		if(index == -1)
			break
		endif
		xtra = text[index, index + 2]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	do
		index = strsearch(text, "\{", 0)
		if(index == -1)
			break
		endif
		closeQuote = strsearch(Text, "}", index + 1)
		xtra = text[index, closeQuote]
		text = ReplaceString(xtra, text, "")
	while(index > -1)

	// @todo if the user's string has a" in it, the text ends there, but I can't
	// figure out how to fix it. At least it doesn't crash.

	// Remove any \ just in case we missed any escape codes.
	text = ReplaceString("\\", text, "", 1)
	return text
End

static Function/T ExtractFont(Text)
	string &Text

	string FontName
	variable index, closeQuote

	index = strsearch(Text, "\F", 0) // Returns position of \F, if there is one.
	if(index > -1)
		CloseQuote = strsearch(Text, "'", index + 3)
		FontName = Text[index + 3, CloseQuote - 1]
		Text = ReplaceString("\F'" + FontName + "'", text, "")
		return FontName
	else
		return ""
	endif
End

static Function ExtractFontSize(text)
	string &text

	variable fontSize
	variable index = strsearch(text, "\Z", 0)
	if(index == -1)
		return 0
	endif

	fontSize = str2num(text[index + 2, index + 3]) /// @todo duplicate code
	text = ReplaceString("\Z" + num2str(fontSize), text, "")
	return Fontsize
End

// Returns a properly formated Plotly string for numbers up to double precision
// (15 sig figs).
static Function/T dub2str(num)
	variable num

	string str
	if(!numtype(num))
		sprintf str, "%.15g", num
	else
		str = "\"NaN\""
	endif

	return ReplaceString(",", str, "")
End

static Function/T WaveToJSONArray(wv)
	wave wv
	variable len = DimSize(wv, 0)
	string out = "[\r"
	variable i = 0
	do
		out += dub2str(wv[i]) + ",\r"
		i += 1
	while (i < len)
	out = out[0, strlen(out) - 3]
	out += "\r]"
	return out
End

static Function/T txtWaveToJSONArray(wv)
	wave/T wv
	variable len = DimSize(wv, 0)
	string out = "[\r"
	string fontName=""
	variable FontSize=0
	variable OZ = 0
	variable i = 0
	do
		out += "\"" + ProcessText(wv[i], fontName, Fontsize, OZ) + "\",\r"
		i += 1
	while (i < len-1)
	out += "\"" + ProcessText(wv[i], fontName, Fontsize, OZ) + "\"\r]"
	return out
End

static Function/T Wave2DToJSONArray(wv, AxisIsSwapped)
	wave wv
	variable AxisIsSwapped
	variable xlen, ylen, i, j
	string out
	if(AxisIsSwapped)
		xlen = DimSize(wv, 1)
		ylen = DimSize(wv, 0)
		out = "[\r"
		i = 0
		j = 0
		do
			out += "[\r"
			do
				out += dub2str(wv[j][i]) + ",\r"
				i += 1
			while (i < xlen)
			i = 0
			j += 1
			out = out[0, strlen(out) - 3]
			out += "\r],\r"
		while (j < ylen)
	else
		xlen = DimSize(wv, 0)
		ylen = DimSize(wv, 1)
		out = "[\r"
		i = 0
		j = 0
		do
			out += "[\r"
			do
				out += dub2str(wv[i][j]) + ",\r"
				i += 1
			while (i < xlen)
			i = 0
			j += 1
			out = out[0, strlen(out) - 3]
			out += "\r],\r"
		while (j < ylen)
	endif

	out = out[0, strlen(out) - 3]
	out += "\r]"
	return out
End

// Set the line dash style
static Function/T AssignLineStyle(lineStyle)
	variable linestyle
	if(lineStyle == 0)
		return ("solid")
	elseif(linestyle == 1)
		return ("1px,1px")
	elseif(linestyle == 2)
		return ("2px,2px")
	elseif(linestyle == 3)
		return ("4px,4px")
	elseif(linestyle == 4)
		return ("1px,2px,3px,2px")
	elseif(linestyle == 5)
		return ("6px,4px,2px,4px")		
	elseif(linestyle == 6)
		return ("7px,2px,2px,2px,2px,2px")	
	elseif(linestyle == 7)
		return ("6px,6px")	
	elseif(linestyle == 8)
		return ("10px,10px")
	elseif(linestyle == 9)
		return ("10px,6px,3px,6px")								
	elseif(linestyle == 10)
		return ("10px,6px,3px,6px,3px,6px")								
	elseif(linestyle == 11)
		return ("5px,2px")								
	elseif(linestyle == 12)
		return ("33px,2px,5px,2px")								
	elseif(linestyle == 13)
		return ("33px,2px,5px,2px,5px,2px")								
	elseif(linestyle == 14)
		return ("33px,2px,5px,2px,5px,2px,5px,2px")								
	elseif(linestyle == 15)
		return ("24px,3px,24px,2px,5px,2px")								
	elseif(linestyle == 16)
		return  ("24px,3px,24px,2px,5px,2px,5px,2px")
	elseif(linestyle == 17)
		return  ("24px,3px,24px,2px,5px,2px,5px,2px,5px,2px")
	endif	
End

/// @param[out] mFill returns new value of mFill
static Function/T AssignMarkerName(MrkrNum, mFill)
	variable MrkrNum, &mFill

	string PlyMrkr

	switch(MrkrNum)
		case 0: // plus
			PlyMrkr = "cross-thin"
			mFill = 0
			break
		case 1: // x
			PlyMrkr = "x-thin"
			mFill = 0
			break
		case 2: // *
			PlyMrkr = "asterisk"
			mFill = 0
			break
		case 3: 
			PlyMrkr = "hourglass"
			mFill = 0
			break
		case 4:
			PlyMrkr = "bowtie"
			mFill = 0
			break
		case 5:
			PlyMrkr = "square"
			break
		case 6:
			PlyMrkr = "triangle-up"
			break
		case 7:
			PlyMrkr = "diamond"
			break
		case 8:
			PlyMrkr = "dot"
			break
		case 9: // hline
			PlyMrkr = "line-ew"
			break
		case 10: // vline
			PlyMrkr = "line-ns"
			break
		case 11: // plusbox
			PlyMrkr = "square-cross"
			break
		case 12: // xbox
			PlyMrkr = "square-x"
			break
		case 13: // dotbox
			PlyMrkr = "square-dot"
			break
		case 14: // hourglass
			PlyMrkr = "hourglass"
			mFill = 1
			break
		case 15: // x-wing
			PlyMrkr = "bowtie"
			mFill = 1
			break
		case 16: // box
			PlyMrkr = "square"
			mFill = 1
			break
		case 17: // triangle-up
			PlyMrkr = "triangle-up"
			mFill = 1
			break
		case 18: // diamond
			PlyMrkr = "diamond"
			mFill = 1
			break
		case 19: // circle
			PlyMrkr = "dot"
			mFill = 1
			break
		case 20: // slash
			PlyMrkr = "line-ne"
			break
		case 21:
			PlyMrkr = "line-nw"
			mFill = 0
			break
		case 22:
			PlyMrkr = "triangle-down"
			mFill = 0
			break
		case 23:
			PlyMrkr = "triangle-down"
			mFill = 1
			break
		case 24:
			PlyMrkr = "triangle-down-dot"
			mFill = 0
			break
		case 25:
			PlyMrkr = "diamond-wide"
			mFill = 0
			break
		case 26:
			PlyMrkr = "diamond-wide"
			mFill = 1
			break
		case 27:
			PlyMrkr = "diamond-wide-dot"
			mFill = 0
			break
		case 28:
			PlyMrkr = "diamond-tall"
			mFill = 0
			break
		case 29:
			PlyMrkr = "diamond-tall"
			mFill = 1
			break
		case 30:
			PlyMrkr = "diamond-tall-dot"
			mFill = 0
			break
		case 31:
			PlyMrkr = "triangle-sw"
			mFill = 0
			break
		case 32:
			PlyMrkr = "triangle-sw"
			mFill = 1
			break
		case 33:
			PlyMrkr = "triangle-se"
			mFill = 0
			break
		case 34:
			PlyMrkr = "triangle-se"
			mFill = 1
			break
		case 35:
			PlyMrkr = "triangle-ne"
			mFill = 0
			break
		case 36:
			PlyMrkr = "triangle-ne"
			mFill = 1
			break
		case 37:
			PlyMrkr = "triangle-nw"
			mFill = 0
			break
		case 38:
			PlyMrkr = "triangle-nw"
			mFill = 1
			break
		case 39:
			PlyMrkr = "hash"
			mFill = 0
			break
		case 40:
			PlyMrkr = "diamond-dot"
			mFill = 0
			break
		case 41:
			PlyMrkr = "circle-dot"
			mFill = 0
			break
		case 42:
			PlyMrkr = "circle-cross"
			mFill = 0
			break
		case 43:
			PlyMrkr = "circle-x"
			mFill = 0
			break
		case 44:
			PlyMrkr = "triangle-up-dot"
			mFill = 0
			break
		case 45:
			PlyMrkr = "triangle-left"
			mFill = 0
			break
		case 46:
			PlyMrkr = "triangle-left"
			mFill = 1
			break
		case 47:
			PlyMrkr = "triangle-left-dot"
			mFill = 0
			break
		case 48:
			PlyMrkr = "triangle-right"
			mFill = 0
			break
		case 49:
			PlyMrkr = "triangle-right"
			mFill = 1
			break
		case 50:
			PlyMrkr = "triangle-right-dot"
			mFill = 0
			break
		case 51:
			PlyMrkr = "pentagon"
			mFill = 0
			break
		case 52:
			PlyMrkr = "pentagon"
			mFill = 1
			break
		case 53:
			PlyMrkr = "pentagon-dot"
			mFill = 0
			break
		case 54:
			PlyMrkr = "hexagon"
			mFill = 0
			break
		case 55:
			PlyMrkr = "hexagon"
			mFill = 1
			break
		case 56:
			PlyMrkr = "hexagon-dot"
			mFill = 0
			break
		case 57:
			PlyMrkr = "star-triangle-up"
			mFill = 0
			break
		case 58:
			PlyMrkr = "star-triangle-up"
			mFill = 1
			break
		case 59:
			PlyMrkr = "star-diamond"
			mFill = 0
			break
		case 60:
			PlyMrkr = "star-diamond"
			mFill = 1
			break
		case 61:
			PlyMrkr = "star-square"
			mFill = 0
			break
		case 62:
			PlyMrkr = "star-square"
			mFill = 1
			break
		default:
			PlyMrkr = "square"
			mFill = 0
	endswitch

	return PlyMrkr
End

static Function/S GoodName(name)
	string name

	variable HasFolder = strsearch(name, ":", 0)
	if(HasFolder < 0)
		name = ReplaceString("'", name, "")
	endif
	return name
End

// This function outputs everything needed after "size": to do an array of sizes
static Function/S zSizeArray(SizeInfo, SizeCode)
	string SizeInfo
	variable SizeCode

	// For markers we need size*2+1, for text markers we need *3. This code tells us what we have. 
	// Actually, if we give Igor a marker size x, igor plots a marker that s 2x+1 point, or (2x+1)*4/3 px because 12pt=16px.
	// Actually, px = pt * ScreenResolution/72, which is the same thing mostly, but we should be as general as possible, so this is better

	string out=""
	string szWave = StringFromList(0, SizeInfo, ",")
	variable zMin = str2num(StringFromList(1, SizeInfo, ","))
	variable zMax =str2num(StringFromList(2, SizeInfo, ","))
	variable mrkmin =str2num(StringFromList(3, SizeInfo, ","))
	variable mrkmax =str2num(StringFromList(4, SizeInfo, ","))
	variable i

	szwave = goodname(szwave)
	Duplicate/O/FREE $szWave zWave
	variable NumSizes = DimSize(zWave, 0)
	variable val
	NVAR LargestMarkerSize = root:Packages:Plotly:LargestMarkerSize

	Make/O/FREE/N=2 SizeWave
	WaveStats/Q $szWave
	variable zmn, zmx, mkmn, mkmx
	if(!numtype(zmin))
		zmn = zmin
	else
		zmn = V_min
	endif
	if(!numtype(zmax))
		zmx = zmax
	else
		zmx = V_max
	endif
	SetScale/I x zmn, zmx, "" SizeWave
	SizeWave[0] = mrkmin
	SizeWave[1] = mrkMax
	print "Markers", MrkMin, MrkMAx
	i=0
	out += "[\r"
	do
		if(zWave[i] < zmn) // This if statement handles marker sizes less than min and max.
			val = zmn
		elseif(zWave[i] > zmx)
			val = zmx
		else
			val = zWave[i]
		endif
		variable PxSize
		if(sizeCode == 2) // Markers
			pxSize = 2 * Mrk2Px(sizewave(val)) * ScreenResolution / 72
		else // Text
			pxSize = Txt2Px(sizewave(val))
		endif
		out += dub2str(pxSize) + ",\r"
		if(pxSize > LargestMarkerSize)
		 	LargestMarkerSize = pxSize // Have to keep of largest marker in the graph, in PX!
		endif
		i += 1
	while(i < numSizes)

	out = out[0, strlen(out) - 3] // Remove the comma after the last data value
	out += "\r]"
	return out
End

static Function/T CreateColorTab(colorinfo, zwave[, cindex])
	string colorinfo, cindex
	wave zwave
	variable index = 0
	if(ParamIsDefault(cindex)) // color table
		variable zMin = str2num(StringFromList(0, Colorinfo, ","))
		variable zMax = str2num(StringFromList(1, Colorinfo, ","))
		string ctName = StringFromList(2, Colorinfo, ",")
		variable ReverseMode = str2num(StringFromList(3, Colorinfo, ","))
		ColorTab2Wave $ctName // Makes a Nx43 matrix for RGB name M_colors
		wave M_colors=M_colors
		variable discrete = DiscreteColorTable(ctName)
	else // color index
		WaveStats/Q zwave
		zMin = V_min
		zMax = V_max
		cindex = goodname(cindex)
		Duplicate/FREE $cindex ciwave
		Duplicate/o ciwave M_colors
		discrete = 1
		index = 1
	endif
	variable numColors = DimSize(M_colors, 0)
	M_colors /= 257 // Plotly is 8-bit
	variable i, j

	string out = "\"colorscale\":[\r" // get ready to write the color scale
	if(reversemode)
		i = 0
		do
			j = (numcolors-1)-i
			out += "[" + dub2str(j / (numColors - 1)) + ",\"rgb(" + dub2str(M_colors[i][0]) + "," + dub2str(M_colors[i][1]) + "," + dub2str(M_colors[i][2]) + ")\"],\r"
			if(discrete && (i < numcolors - 1)) // Make the color table explicitly discrete colors, even in Plotly interpolates
				out += "[" + dub2str((j - 1) / (numColors - 1)) + ",\"rgb(" + dub2str(M_colors[i][0]) + "," + dub2str(M_colors[i][1]) + "," + dub2str(M_colors[i][2]) + ")\"],\r"
			endif
			i += 1
		while(i < numcolors)
	else
		i = 0
		do
			out += "[" + dub2str(i / (numColors - 1)) + ",\"rgb(" + dub2str(M_colors[i][0]) + "," + dub2str(M_colors[i][1]) + "," + dub2str(M_colors[i][2]) + ")\"],\r"
			if(discrete && (i < numcolors - 1)) // Make the color table explicitly discrete colors, even in Plotly interpolates
				out += "[" + dub2str((i + 1)/(numColors-1)) + ",\"rgb(" + dub2str(M_colors[i][0]) + "," + dub2str(M_colors[i][1]) + "," + dub2str(M_colors[i][2]) + ")\"],\r"
			endif
			i += 1
		while(i < numcolors)
	endif
	out = out[0, strlen(out) - 3]
	out += "\r],\r"
	WaveStats/Q zwave
	variable zlo, zhi
	if(!numtype(zmin))
		zlo = zmin
	else
		zlo = V_min
	endif
	if(!numtype(zmax))
		zHi = zmax
	else
		zHi = V_Max
	endif
	zmin = zlo
	zmax = zhi
	out += "\"zmin\":" + dub2str(zmin) + ",\r"
	out += "\"zmax\":" + dub2str(zmax) + ",\r"
	out += "\"zauto\":false,\r"
	return out

	// Logarithmic Indexed Color
	// For logarithmic indexed color (the ModifyImage log parameter is set to 1), colors are mapped using the log(x scaling) and log(image z) values this way:
	// colorIndexWaveRow = floor(nRows*(log(zImageValue)-log(xMin))/(log(xmax)-log(xMin)))
	// where,
	// nRows = DimSize(colorIndexWave, 0)
	// xMin = DimOffset(colorIndexWave, 0)
	// xMax = xMin + (nRows-1) * DimDelta(colorIndexWave, 0)
	// Displaying image data in log mode will be slower than in linear mode.
End

// This function outputs everything needed after "color": to do an array of
// colors.
static Function/T zColorArray(colorinfo, mode[, transp])
	string colorinfo
	string mode // This is required because text graphs aren't compatible with colorscales
	variable transp // An optional parameter to set the transparency.
	if(ParamIsDefault(transp))
		transp = 1
	endif

	variable i, val

	string out = ""
	string szWave = StringFromList(0, Colorinfo, ",")
	variable zMin = str2num(StringFromList(1, Colorinfo, ","))
	variable zMax = str2num(StringFromList(2, Colorinfo, ","))
	string ctName = StringFromList(3, Colorinfo, ",")
	string ReverseMode = StringFromList(4, Colorinfo, ",")
	string ciWave = StringFromList(5, Colorinfo, ",")

	szWave = goodname(szWave)
	Duplicate/O/FREE $szWave zWave
	variable NumColors = DimSize(zWave, 0)
	if(StringMatch(ctName, "cindexRGB"))
		Print "COLOR ERROR : cindex"
	elseif(StringMatch(ctName, "directRGB"))
		print "COLOR ERROR : directRBG"
	else // color table
		ColorTab2Wave $ctName // Makes a Nx43 matrix for RGB name M_colors
		wave M_colors
		numColors = DimSize(zwave, 0)	// Make a color entry for each point
		M_colors /= 257 // Plotly is 8-bit
		WaveStats/Q $szWave
		variable zmn, zmx, mkmn, mkmx
		if(!numtype(zmin))
			zmn = zmin
		else
			zmn = V_min
		endif
		if(!numtype(zmax))
			zmx = zmax
		else
			zmx = V_max
		endif

		Duplicate/O M_colors m_test /// @todo delete debug statement
		if(str2num(ReverseMode)==1)
			SetScale/I x zmx, zmn, "" M_colors
		else
			SetScale/I x zmn, zmx, "" M_colors
		endif
		i = 0
		out += "[\r"

		do

			if(zWave[i] < zmn) // This if statement handles color sizes less than min and max.
				val = zmn
			elseif(zWave[i] > zmx)
				val = zmx
			else
				val = zWave[i]
			endif
			out += "\"rgba(" + dub2str(interp2d(M_colors, val, 0)) + "," + dub2str(interp2d(M_colors, val, 1)) + "," + dub2str(interp2d(M_colors, val, 2)) + " +" + dub2str(transp) + ")\",\r"
			i += 1
		while(i < numColors)
		out = out[0, strlen(out) - 3] // Remove the comma after the last data value
		out += "\r]"
	endif
	return out
End

static Function/T CreateContourObj(contour, graph)
	string contour, graph
	string info = contourinfo(graph, contour, 0)
	string obj = "{\r"

	// Sort out the axes
	SVAR HaxisList = root:Packages:Plotly:HAxisList
	SVAR VaxisList = root:Packages:Plotly:VAxisList
	string XAxis = StringByKey("XAXIS", info, ":", ";", 1) // Get the name of the x-axis, but in Igor this does not have to be horizontal
	string YAxis = StringByKey("YAXIS", info, ":", ";", 1) // Get the name of the y-axis, but in Igor this does not have to be vertical
	string AxisFlags = StringByKey("AXISFLAGS", info, ":", ";", 1)
	string Lnam = StringByKey("L", AxisFlags, "=", "/", 1)
	string Tnam = StringByKey("T", AxisFlags, "=", "/", 1)
	string Rnam = StringByKey("R", AxisFlags, "=", "/", 1)
	string Bnam = StringByKey("B", AxisFlags, "=", "/", 1)
	variable rgbR, rgbG, rgbB
	variable setlinecolor=0

	// Look out for axis swap and add names of axes to a vertical and horizontal list
	variable axisISswapped = 0
	if(StringMatch(Xaxis, "right") || StringMatch(Xaxis, "left") || StringMatch(Xaxis, Lnam) || StringMatch(Xaxis, Rnam))
		// The axes are swapped because the x-data are plotted along a vertical axis.
		axisISswapped = 1
		variable HaxNum = WhichListItem(YAxis, Haxislist) // This returns a number from the list, -1 if the axis name has not yet been used.
		variable Vaxnum = WhichListItem(XAxis, Vaxislist) // This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum < 0) // The axis has not already been used, write it to the local list of horizontal-axes
			Haxislist += yAxis + ";"
			HaxNum = WhichListItem(yAxis, HaxisList)
		endif
		if(VaxNum < 0) // The axis has not already been used, write it to the local list of vertical-axes
			Vaxislist += xAxis + ";"
			VaxNum = WhichListItem(xAxis, VaxisList)
		endif
	else // axes not swapped.
		HaxNum = WhichListItem(XAxis, HaxisList) // This returns a number from the list, -1 if the axis name has not yet been used.
		VaxNum = WhichListItem(YAxis, VaxisList) // This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum < 0) // The axis has not already been used, write it to the local list of x-axes
			Haxislist += xAxis + ";"
			HaxNum = WhichListItem(xAxis, HaxisList)
		endif
		if(VaxNum < 0) // The axis has not already been used, write it to the local list of y-axes
			Vaxislist += yAxis + ";"
			VaxNum = WhichListItem(yAxis, VaxisList)
		endif
	endif

	// Now, write the horizontal and vertical axis number to plotly, unless it is the first instance, in which case write nothing.
	if(HaxNum > 0)
		obj += "\"xaxis\":\"x" + dub2str(HaxNum + 1) + "\",\r"  // if igor axis number is > 0, write plotly axis number > 1
	endif
	if(VaxNum > 0)
		obj += "\"yaxis\":\"y" + dub2str(VaxNum + 1) + "\",\r"  // if igor axis number is > 0, write plotly axis number > 1
	endif

	// Get the data
	string xwave = StringByKey("XWAVEDF", info, ":", ";", 1) + StringByKey("XWAVE", info, ":", ";", 1)
	string ywave = StringByKey("YWAVEDF", info, ":", ";", 1) + StringByKey("YWAVE", info, ":", ";", 1)
	string zwave = StringByKey("ZWAVEDF", info, ":", ";", 1) + StringByKey("ZWAVE", info, ":", ";", 1)

	variable x0 = DimOffset($Zwave, 0)
	variable dx = DimDelta($Zwave, 0)
	variable y0 = DimOffset($Zwave, 1)
	variable dy = DimDelta($Zwave, 1)
	if(StringMatch(xwave, "")) // notplotted against an x-wave
		obj += "\"x0\":" + dub2str(x0) + ",\r"
		obj += "\"dx\":" + dub2str(dx) + ",\r"
	else
		if(axisisswapped)
			obj += "\"y\":" + WaveToJSONArray($(xwave)) + ",\r"
		else
			obj += "\"x\":" + WaveToJSONArray($(xwave)) + ",\r"
		endif
	endif
	if(StringMatch(ywave, "")) // notplotted against a y-wave
		obj += "\"y0\":" + dub2str(y0) + ",\r"
		obj += "\"dy\":" + dub2str(dy) + ",\r"
	else
		if(axisisswapped)
			obj += "\"x\":" + WaveToJSONArray($(ywave)) + ",\r"
		else
			obj += "\"y\":" + WaveToJSONArray($(ywave)) + ",\r"
		endif
	endif
	obj += "\"z\":" + Wave2DtoJSONArray($zwave, axisIsSwapped) + ",\r"

	// Get the colorscale or color
	variable ctabStart = strsearch(info, "ctabLines", 0)
	variable cindexStart = strsearch(info, "cindexLines", 0)
	if(ctabstart > -1) // This is a color table contour
		variable ctabR = strsearch(info, ";", ctabStart)
		string ctab = info[ctabstart + 11, ctabR - 2]
		obj += CreateColorTab(ctab, $zWave)
	elseif(cindexStart > -1) // This is a color index contour
		ctabR = strsearch(info, ";", cindexstart)
		ctab = info[cindexstart + 12, ctabR - 1]
		obj += CreateColorTab("Cindex", $zWave, cindex = ctab)
	else // We specify an RGB for the contour.
	 	ctab = StringByKey("rgbLines", info, "=", ";", 1)
		ctab = "color(x)=" + ctab // Add a key for the standard format for the key searcher
		rgbR = round(GetNumFromModifyStr(ctab, "color", "(", 0) / 257)
		rgbG = round(GetNumFromModifyStr(ctab, "color", "(", 1) / 257)
		rgbB = round(GetNumFromModifyStr(ctab, "color", "(", 2) / 257)
		SetLineColor = 1
	endif

	// Do contour specific things
	obj += "\"contours\":{\r"
	if(setlinecolor)
		obj += "\"coloring\":\"none\",\r"
	else
		obj += "\"coloring\":\"lines\",\r"
	endif
	obj += "\"showlines\":true,\r"
	string levelslist = StringByKey("LEVELS", info, ":", ";", 1)
	variable NumLevels = itemsinlist(Levelslist, ",")
	string FirstLevel = StringFromList(0, LevelsList, ",")
	string SecondLevel = StringFromList(1, LevelsList, ",")
	string LastLevel = StringFromList(NumLevels - 1, LevelsList, ",")
	obj += "\"start\":" + FirstLevel + ",\r"
	obj += "\"end\":" + LastLevel + ",\r"
	// Assume the level spacing is even, since that's what Plotly does
	obj += "\"size\":" + dub2str(str2num(SecondLevel) - str2num(FirstLevel)) + ",\r"
	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r" // End of "contours"
	obj += "\"ncontours\":" + dub2str(NumLevels) + ",\r"

	obj += "\"line\":{\r"
	if(setlinecolor)
		obj += "\"color\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"
	endif
	obj += "\"width\":1\r"
	obj += "},\r"
	obj += "\"autocontour\":false,\r"
	obj += "\"type\":\"contour\",\r"
	obj += "\"name\":\"" + contour + "\",\r"

	// Check for colorbars and add them if present, in plotly they are part of the heatmap object------------------------------------------------------------------------------------------------------	
	string list = annotationlist(graph)
	variable index=0
	string AnnotationName
	variable ColorscaleCreated = 0
	string CsObj
	do // annotations
		AnnotationName = StringFromList(index, List)
		if(strlen(AnnotationName) == 0)
			break // no more anotations, so move on to next section
		endif
		CSobj = CreateColorScaleObj(AnnotationName, graph, contour) /// the 1 at the end specifies all types of annotation except colorscales, which have to be inserted with the image object
		obj += CSobj
		if(!StringMatch(CSobj, "") ) // We created a colorscale, no need to disable colorscale
			ColorscaleCreated = 1
			endif
		index += 1
	while(1)
	if(colorscaleCreated == 0)
		obj += "\"showscale\":false,\r"
	endif
	obj = obj[0, strlen(obj) - 3]
	obj += "\r}\r"
	return obj
End

static Function/T createImageObj(image, graph)
	string image, graph
	string info = imageinfo(graph, image, 0)
	string obj = "{\r"

	// Sort out the axes
	SVAR HaxisList = root:Packages:Plotly:HAxisList
	SVAR VaxisList = root:Packages:Plotly:VAxisList
	string XAxis = StringByKey("XAXIS", info, ":", ";", 1) // Get the name of the x-axis, but in Igor this does not have to be horizontal
	string YAxis = StringByKey("YAXIS", info, ":", ";", 1) // Get the name of the y-axis, but in Igor this does not have to be vertical
	string AxisFlags = StringByKey("AXISFLAGS", info, ":", ";", 1)
	string Lnam = StringByKey("L", AxisFlags, "=", "/", 1)
	string Tnam = StringByKey("T", AxisFlags, "=", "/", 1)
	string Rnam = StringByKey("R", AxisFlags, "=", "/", 1)
	string Bnam = StringByKey("B", AxisFlags, "=", "/", 1)

	// Look out for axis swap and add names of axes to a vertical and horizontal list
	variable axisISswapped = 0
	if(StringMatch(Xaxis, "right") || StringMatch(Xaxis, "left") || StringMatch(Xaxis, Lnam) || StringMatch(Xaxis, Rnam))
		// The axes are swapped because the x-data are plotted along a vertical axis.
		axisISswapped = 1
		variable HaxNum = WhichListItem(YAxis, Haxislist) // This returns a number from the list, -1 if the axis name has not yet been used.
		variable Vaxnum = WhichListItem(XAxis, Vaxislist) // This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum < 0) // The axis has not already been used, write it to the local list of horizontal-axes
			Haxislist += yAxis + ";"
			HaxNum = WhichListItem(yAxis, HaxisList)
		endif
		if(VaxNum < 0) // The axis has not already been used, write it to the local list of vertical-axes
			Vaxislist += xAxis + ";"
			VaxNum = WhichListItem(xAxis, VaxisList)
		endif
	else // axes not swapped.
		HaxNum = WhichListItem(XAxis, HaxisList)			 // This returns a number from the list, -1 if the axis name has not yet been used.
		VaxNum = WhichListItem(YAxis, VaxisList)			 // This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum < 0) // The axis has not already been used, write it to the local list of x-axes
			Haxislist += xAxis + ";"
			HaxNum = WhichListItem(XAxis, HaxisList)
		endif
		if(VaxNum < 0) // The axis has not already been used, write it to the local list of y-axes
			Vaxislist += yAxis + ";"
			VaxNum = WhichListItem(YAxis, VaxisList)
		endif
	endif

	// Now, write the horizontal and vertical axis number to plotly, unless it is the first instance, in which case write nothing.
	if(HaxNum > 0)
		obj += "\"xaxis\":\"x" + dub2str(HaxNum > 1) + "\",\r"  // if igor axis number is > 0, write plotly axis number > 1
	endif
	if(VaxNum > 0)
		obj += "\"yaxis\":\"y" + dub2str(VaxNum > 1) + "\",\r"  // if igor axis number is > 0, write plotly axis number > 1
	endif

	// Get the data
	string xwave = StringByKey("XWAVEDF", info, ":", ";", 1) + StringByKey("XWAVE", info, ":", ";", 1)
	string ywave = StringByKey("YWAVEDF", info, ":", ";", 1) + StringByKey("YWAVE", info, ":", ";", 1)
	string zwave = StringByKey("ZWAVEDF", info, ":", ";", 1) + StringByKey("ZWAVE", info, ":", ";", 1)

	variable x0 = DimOffset($Zwave, 0)
	variable dx = DimDelta($Zwave, 0)
	variable y0 = DimOffset($Zwave, 1)
	variable dy = DimDelta($Zwave, 1)
	if(StringMatch(xwave, "")) // notplotted against an x-wave
		obj += "\"x0\":" + dub2str(x0) + ",\r"
		obj += "\"dx\":" + dub2str(dx) + ",\r"
	else
		if(axisisswapped)
			obj += "\"y\":" + WaveToJSONArray($(xwave)) + ",\r"
		else
			obj += "\"x\":" + WaveToJSONArray($(xwave)) + ",\r"
		endif
	endif
	if(StringMatch(ywave, "")) // notplotted against a y-wave
		obj += "\"y0\":" + dub2str(y0) + ",\r"
		obj += "\"dy\":" + dub2str(dy) + ",\r"
	else
		if(axisisswapped)
			obj += "\"x\":" + WaveToJSONArray($(ywave)) + ",\r"
		else
			obj += "\"y\":" + WaveToJSONArray($(ywave)) + ",\r"
		endif
	endif
	obj += "\"z\":" + Wave2DtoJSONArray($zwave, axisIsSwapped) + ",\r"
	// Get the colorscale
	variable ctabStart = strsearch(info, "ctab", 0)
	if(ctabStart > -1) // We DO have a color table
		variable ctabR = strsearch(info, ";", ctabStart)
		string ctab = info[ctabstart + 7, ctabR - 2]
		obj += CreateColorTab(ctab, $zWave)
	else // We do not have a color table, we must have a color index
		ctabstart = strsearch(info, "cindex", 0)
		ctabR = strsearch(info, ";", ctabstart)
		ctab = info[ctabstart + 7, ctabR - 1]
		obj += CreateColorTab("Cindex", $zWave, cindex = ctab)
	endif

	obj += "\"type\":\"heatmap\",\r"
	obj += "\"name\":\"" + image + "\",\r"
	// check for colorbars and add them if present. In plotly they are part of the heatmap object
	string list = annotationlist(graph)
	variable index=0
	string AnnotationName
	variable ColorscaleCreated = 0
	string CsObj
	do // annotations
		AnnotationName = StringFromList(index, List)
		if(strlen(AnnotationName) == 0)
			break // no more anotations, so move on to next section
		endif
		CSobj = CreateColorScaleObj(AnnotationName, graph, image) /// the 1 at the end specifies all types of annotation except colorscales, which have to be inserted with the image object
		obj += CSobj
		if(!StringMatch(CSobj, "") ) // We created a colorscale, no need to disable colorscale
			ColorscaleCreated = 1
		endif
		index += 1
	while(1)
	if(colorscaleCreated == 0)
		obj += "\"showscale\":false,\r"
	endif
	obj = obj[0, strlen(obj) - 3]
	obj += "\r}\r"
	return obj
End

// Make arrays for color and symbol
static Function AssignMarkerNameArray(MrkNumZwave, MRK_Array, MRK_RGBArray, TraceRGB, UseZColor, RGB_Array, opaque)
	string MrkNumZwave, &Mrk_Array, &MRK_RGBArray, TraceRGB, RGB_Array
	variable opaque, useZcolor

	string PlyMrkr
	variable mFill, len
	variable i = 0
	string RGB=""

	Mrk_Array = "[\r"
	MRk_RGBArray = "[\r"
	MrkNumZwave = goodname(mrknumzwave)
	Duplicate/O/FREE $MrkNumzWave MrkWave
	len = DimSize(MrkWave, 0)

	do
		PlyMrkr = AssignMarkerName(MrkWave[i], mFill)	// Function to assign marker name from the wave
		Mrk_Array += "\"" + PlyMrkr + "\",\r"
		if(MFill == 0 && !opaque)	// This is an non-filled marker type and not opaque
			Mrk_RGBArray += "\"rgba(0,0,0,0)\",\r"
		elseif(MFill == 0 && opaque) // This is a non-filled marker type but it's opaque (white)
			Mrk_RGBArray += "\"rgb(255,255,255)\",\r"
		elseif(UseZColor) // The marker color is an array
			RGB = StringFromList(i, RGB_Array, "\r")
			Mrk_RGBArray += RGB + "\r"
		else // The marker is filled-type, and set by the main trace color
			Mrk_RGBArray += TraceRGB + ",\r"
		endif
		i += 1
	while(i < len)
	Mrk_Array = Mrk_array[0, strlen(Mrk_array) - 3]
	Mrk_RGBArray = Mrk_RGBarray[0, strlen(Mrk_RGBarray) - 3]
	mrk_Array += "\r]"
	mrk_RGBArray += "\r]"
End

static Function/T CreateTrObj(traceName, graph)
	string traceName, graph

	string plyName = traceName

	string info = TraceInfo(graph, traceName, 0)
	variable txtMrk
	variable mode = GetNumFromModifyStr(info, "mode", "", 0)
	string plyMode
 	variable AutoX = 0 // Set this flag to zero assumes user supplied a numeric x-wave
 	variable CategoryPlot = 0 // Assume this graph is not a category plot
	string obj = "{\r" // Opening bracket for the entire data section.

	// Sort-out the Axis Names

	// The strategy is to use Igor axis names in Igor, and plotly axis names (is, x, x2, x3, ...) in plotly
	SVAR HaxisList = root:Packages:Plotly:HAxisList
	SVAR VaxisList = root:Packages:Plotly:VAxisList
	NVAR defaultMarkerSize = root:Packages:Plotly:defaultMarkerSize // In Igor size, not points	
	NVAR defaultTextSize = root:Packages:Plotly:DefautTextSize
	NVAR MarkerFlag = root:Packages:Plotly:MarkerFlag
	NVAR LargestMarkerSize = root:Packages:Plotly:LargestMarkerSize
	SVAR BarToMode = root:packages:Plotly:BarToMode
	NVAR catCount = root:packages:Plotly:CatCount
	NVAR TraceOrderFlag = root:packages:Plotly:TraceOrderFlag
	string XAxis = StringByKey("XAXIS", info, ":", ";", 1) // Get the name of the x-axis, but in Igor this does not have to be horizontal
	string YAxis = StringByKey("YAXIS", info, ":", ";", 1) // Get the name of the y-axis, but in Igor this does not have to be vertical
	string AxisFlags = StringByKey("AXISFLAGS", info, ":", ";", 1)
	string Lnam = StringByKey("L", AxisFlags, "=", "/", 1)
	string Tnam = StringByKey("T", AxisFlags, "=", "/", 1)
	string Rnam = StringByKey("R", AxisFlags, "=", "/", 1)
	string Bnam = StringByKey("B", AxisFlags, "=", "/", 1)

	// Look out for axis swap and add names of axes to a vertical and horizontal list
	variable axisISswapped = 0
	if(StringMatch(Xaxis, "right") || StringMatch(Xaxis, "left") || StringMatch(Xaxis, Lnam) || StringMatch(Xaxis, Rnam))
		// The axes are swapped because the x-data are plotted along a vertical axis.
		axisISswapped = 1
		variable HaxNum = WhichListItem(YAxis, Haxislist) // This returns a number from the list, -1 if the axis name has not yet been used.
		variable Vaxnum = WhichListItem(XAxis, Vaxislist) // This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum < 0) // The axis has not already been used, write it to the local list of horizontal-axes
			Haxislist += yAxis + ";"
			HaxNum = WhichListItem(yAxis, HaxisList)
		endif
		if(VaxNum < 0) // The axis has not already been used, write it to the local list of vertical-axes
			Vaxislist += xAxis + ";"
			VaxNum = WhichListItem(xAxis, VaxisList)
		endif
	else // axes not swapped.
		HaxNum = WhichListItem(XAxis, HaxisList) // This returns a number from the list, -1 if the axis name has not yet been used.
		VaxNum = WhichListItem(YAxis, VaxisList) // This returns a number from the list, -1 if the axis name has not yet been used.
		if(HaxNum < 0) // The axis has not already been used, write it to the local list of x-axes
			Haxislist += xAxis + ";"
			HaxNum = WhichListItem(XAxis, HaxisList)
		endif
		if(VaxNum < 0) // The axis has not already been used, write it to the local list of y-axes
			Vaxislist += yAxis + ";"
			VaxNum = WhichListItem(YAxis, VaxisList)
		endif
	endif

	// Now, write the horizontal and vertical axis number to plotly, unless it is the first instance.
	if(HaxNum > 0)
		obj += "\"xaxis\":\"x" + dub2str(HaxNum + 1) + "\", \r"
	endif
	if(VaxNum > 0)
		obj += "\"yaxis\":\"y" + dub2str(VaxNum + 1) + "\", \r"
	endif
	// Done sorting out the axes

	wave Tempyw = TraceNameToWaveRef(graph, traceName)
	Duplicate/O/FREE Tempyw yw // We do this duplication so that if we change the wave (ie, for cityscape or bar) it doesn't change locally
	variable trLen = DimSize(yw, 0)
	if(!WaveExists(XWaveRefFromTrace(graph, traceName))) // Not plotted against x-wave, in other words, use igor Wave scaling.
		Duplicate/O/FREE yw xw
		xw = x
		AutoX=1
	else
		 wave TempXw = XWaveRefFromTrace(graph, traceName)
		Duplicate/O/FREE TempXw xw
	endif
	if(!WaveType(xw)) // The x-wave is not numeric...this is a category plot
		CategoryPlot = 1
	endif
	variable toMode = GetNumFromModifyStr(info, "toMode", "", 0)
	plyMode = "bars"
 	switch(mode)

	// --+----------------------
	// m | igor type
	// --+----------------------
 	// 0 | Lines between points.
	// 1 | Sticks to zero.
	// 2 | Dots at points.
	// 3 | Markers.
	// 4 | Lines and markers.
	// 5 | Histogram bars.
	// 6 | Cityscape.
	// 7 | Fill to zero.
	// 8 | Sticks and markers.
	// --+----------------------

 		case 0:
 			plyMode = "lines"
 			break
 		case 2: // Dots at points
 			plyMode = "markers"
 			break
 		case 3: // Markers
 			txtMrk = GetNumFromModifyStr(info, "textMarker", "", 0)
			if(!numtype(txtMrk)) // txtMrk is a number, meaning there are no text markers in the trace
				plyMode = "markers"
			else // We have a text graph
				plyMode = "text"
			endif
			break
		case 4:
			txtMrk = GetNumFromModifyStr(info, "textMarker", "", 0)
			if(!numtype(txtMrk)) // txtMrk is a number, meaning there are no text markers in the trace
				plyMode = "lines, markers"
			else // We have a text graph
				plyMode = "lines, text"
			endif
			break
		case 5: // Bars. But we need to handle it differently if not category plot...instead use cityscape and fill to zero.
			if(categoryplot == 0) // So this is NOT a category plot, so it isn't a plotly bar chart.
				plyMode = "lines"
				if(AutoX) // We are using Igor scaling, so we need to add an extra point at the end to Make the Plotly graph look like the Igor graph
					InsertPoints trLen, 1, xw, yw
					xw = x
					yw[trLen] = yw[trLen-1]
					trLen += 1
				endif
				mode = 6
				print "NOTE: Strokes will not be rendered correctly in Plotly. Consider switching to Igor category mode for more bar chart control."
			else // This graph has a category plot, it will be a proper Plotly histogram.
				plyMode = "bar"
				catCount = trLen
				if(StringMatch(BarToMode, "NULL")) // No grouping mode has yet been set for bars. Use the first instance of a bar to set this mode for Plotly, which only allows a global gouping mode
					if(toMode == -1)
						BarToMode = "overlay"
					elseif(toMode == 2 || toMode == 3)
						BarToMode = "stack"
						TraceOrderFlag = 1 // We have to reverse the order for stacked bars
					else
						BarToMode = "group"
					endif
				endif
			endif
			break
		case 6: // For cityscape, send a lines-only graph, but be sure to set "hv" in lines properties
			plyMode = "lines"
			if(AutoX) // We are using Igor scaling, so we need to add an extra point at the end to Make the Plotly graph look like the Igor graph
				InsertPoints trLen, 1, xw, yw
				xw = x
				yw[trLen] = yw[trLen-1]
				trLen += 1
			endif
			break
		case 7: // Fill to zero is a line, no markers, with a fill setting
			plyMode = "lines"
			break
	endswitch

	if(axisISswapped)
		if(CategoryPlot)
			obj += "\"y\":" + TxtWaveToJSONArray(xw) + ",\r"
		elseif(AutoX) // Use Igor Scaling
			obj += "\"y0\":" + dub2str(DimOffset(yw, 0)) + ",\r"
			obj += "\"dy\":" + dub2str(DimDelta(yw, 0)) + ",\r"
		else
			obj += "\"y\":" + WaveToJSONArray(xw) + ",\r"
		endif
		obj += "\"x\":" + WaveToJSONArray(yw) + ",\r"
	else
		if(CategoryPlot)
			obj += "\"x\":" + TxtWaveToJSONArray(xw) + ",\r"
		elseif(AutoX) // Use Igor Scaling
			obj += "\"x0\":" + dub2str(DimOffset(yw, 0)) + ",\r"
			obj += "\"dx\":" + dub2str(DimDelta(yw, 0)) + ",\r"
		else
			obj += "\"x\":" + WaveToJSONArray(xw) + ",\r"
		endif
		obj += "\"y\":" + WaveToJSONArray(yw) + ",\r"
	endif

	// Get the main color information for this trace.
	string RGB_Array=""		// We'll store data here if a color array is needed
	variable rgbR = round(GetNumFromModifyStr(info, "rgb", "(", 0)/257)
	variable rgbG = round(GetNumFromModifyStr(info, "rgb", "(", 1)/257)
	variable rgbB = round(GetNumFromModifyStr(info, "rgb", "(", 2)/257)
	string TraceRGB = "\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\""
	variable hbFill = GetNumFromModifyStr(info, "hbFill", "", 0)
	variable FillA = 1
	if(hbFill == 0)
		FillA = 0
	elseif(hbFill == 1)
		fillA = 0 // @todo this mode should go to the background color.
	elseif(hbFill == 2)
		FillA = 1
	elseif(hbFill == 3)
		FillA = 0.75
	elseif(hbFill == 4)
		FillA = 0.5
	elseif(hbFill == 5)
		FillA = 0.25
	elseif(hbFill > 5) // No patterns in Plotly, that I know of.
		FillA = 0.5
	endif
	variable useZcolor = numtype(GetNumFromModifyStr(info, "zColor", "", 0))
	if(useZcolor) // This expression is true if we are using color as f(z), so we create a color array
	 	string ColorInfo = StringByKey("zColor(x)", info, "=", ";") // First check for zColor
	 	if(StringMatch(ColorInfo, ""))
	 		Colorinfo = StringByKey("RECREATION:zColor(x)", info, "=", ";") // usually, this is the right key. But may be not always, so keep the if
	 	endif
	 	Colorinfo = colorinfo[1, strlen(colorinfo) - 2] // Strip off the { }
	 	RGB_Array = zColorArray(ColorInfo, plyMode)
	endif
	variable lineSize = GetNumFromModifyStr(info, "lSize", "", 0)


	// Do things specific to category bar mode.
	if(strsearch(plyMode, "bar", 0) > -1) // Bar mode
		variable UseBarStroke = GetNumFromModifyStr(info, "useBarStrokeRGB", "", 0)
		if(UseBarStroke)
			variable BarStrkR = round(GetNumFromModifyStr(info, "barStrokeRGB", "(", 0) / 257)
			variable BarStrkG = round(GetNumFromModifyStr(info, "barStrokeRGB", "(", 1) / 257)
			variable BarStrkB = round(GetNumFromModifyStr(info, "barStrokeRGB", "(", 2) / 257)
			string BarStrkRGB = "\"rgb(" + dub2str(BarStrkR) + "," + dub2str(BarStrkG) + "," + dub2str(BarStrkB) + ")\""
		elseif(useZcolor)
			BarStrkRGB = RGB_Array
		else
			BarStrkRGB = "\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\""
		endif
		variable UsePlusRGB = GetNumFromModifyStr(info, "usePlusRGB", "", 0)
		if(UsePlusRGB) // These colors have the possiblity of transparency, based on hbFill, set above
			variable BarR = round(GetNumFromModifyStr(info, "plusRGB", "(", 0) / 257)
			variable BarG = round(GetNumFromModifyStr(info, "plusRGB", "(", 1) / 257)
			variable BarB = round(GetNumFromModifyStr(info, "plusRGB", "(", 2) / 257)
			string BarRGB = "\"rgba(" + dub2str(barR) + "," + dub2str(BarG) + "," + dub2str(BarB) + "," + dub2str(FillA) + ")\""
		elseif(useZcolor)
			BarRGB = zColorArray(Colorinfo, plyMode, transp=FillA)
		else
			BarRGB = "\"rgba(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + "," + dub2str(FillA) + ")\""
		endif
		obj += "\"marker\":{\r"
		obj += "\"color\":" + BarRGB + ",\r"
		obj += "\"line\":{\r"
		obj += "\"color\":" + BarStrkRGB + ",\r"
		obj += "\"width\":" + dub2str(lineSize) + "\r"
		obj += "}\r"
		obj += "},\r"
	endif

	// Set LINE information
	if(strsearch(plyMode, "lines", 0) > -1) // the Plotly mode contains a line, so send information about the line
		variable lineStyle = GetNumFromModifyStr(info, "lStyle", "", 0)
		string PlyDash = AssignLineStyle(LineStyle)
		obj += "\"line\":{\r"
		if(mode==6) // Cityscape
			obj += "\"shape\":\"hv\",\r"
		endif
		obj += "\"color\":" + TraceRGB + ",\r"
		obj += "\"dash\":\"" + PlyDash + "\",\r"
		obj += "\"width\":" + dub2str(lineSize) + "\r"
		obj += "},\r"
	endif
	// End of LINE information

	// Fill information for Fill to Zero
	if(mode == 7 || mode == 6)
			variable PlusrgbR, plusrgbG, plusrgbB
			if(tomode == 1) // Fill to next, but in Plotly it's fill to last so reverst the ordering
				TraceOrderFlag=1
				obj += "\"fill\":\"tonexty\",\r"
			else
				obj += "\"fill\":\"tozeroy\",\r"
			endif
			if(GetNumFromModifyStr(info, "usePlusRGB", "", 0))
				PlusrgbR = round(GetNumFromModifyStr(info, "plusRGB", "(", 0) / 257)
				PlusrgbG = round(GetNumFromModifyStr(info, "plusRGB", "(", 1) / 257)
				PlusrgbB = round(GetNumFromModifyStr(info, "plusRGB", "(", 2) / 257)
			else
				PlusrgbR = rgbR
				PlusrgbG = rgbG
				PlusrgbB = rgbB
			endif
			obj += "\"fillcolor\":\"rgba(" + dub2str(PlusrgbR) + "," + dub2str(PlusrgbG) + "," + dub2str(PlusrgbB) + "," + dub2str(FillA) + ")\",\r"
	endif
	// End of Fill to Zero information

	// Markers
	// =======
	// The Plotly mode contains a marker or text marker, so send information about the marker
 	if(strsearch(plyMode, "markers", 0) > -1 || strsearch(plyMode, "text", 0) > -1)
		MarkerFlag = 1
		string PlyMrkr
		variable mFill = 0 // This flag will be set to 1 if we need to fill our marker
		variable MrkrSize = GetNumFromModifyStr(info, "msize", "", 0)
		if(MrkrSize == 0)
			MrkrSize = defaultMarkerSize
		endif
		variable MrkrrgbR = round(GetNumFromModifyStr(info, "mrkStrokeRGB", "(", 0)/257) // These are the marker stroke colors reported by Igor
		variable mrkrrgbG = round(GetNumFromModifyStr(info, "mrkStrokeRGB", "(", 1)/257)
		variable MrkrrgbB = round(GetNumFromModifyStr(info, "mrkStrokeRGB", "(", 2)/257)
		string MarkerRGB = "\"rgb(" + dub2str(MrkrrgbR) + "," + dub2str(MrkrrgbG) + "," + dub2str(MrkrrgbB) + ")\""
		variable UseMrkrStroke = GetNumFromModifyStr(info, "useMrkStrokeRGB", "", 0)
		variable opaque = GetNumFromModifyStr(info, "opaque", "", 0)
		string PlyMarkerColor // We'll set this in the decision tree
		string PlyStrokeColor // We'll set this in the decision tree
		string SIZE_Array
		variable sizeCode
		variable useZsize = numtype(GetNumFromModifyStr(info, "zmrkSize", "", 0))
		variable useZmrkNum = numtype(GetNumFromModifyStr(info, "zmrkNum", "", 0))

		if((strsearch(plyMode, "markers", 0) > -1) && !(mode == 2)) // We have markers and not dots at points
			if(MrkrSize) // Adjust the marker size if not set to autosize (0)
				MrkrSize = Mrk2Px(MRkrSize) // Convert to screen px for Plotly
				if(MrkrSize > LargestMarkerSize)
				 	LargestMarkerSize = MrkrSize
				 endif
				SizeCode = 2
			endif
			variable MrkrThick = GetNumFromModifyStr(info, "mrkThick", "", 0)
			obj += "\"marker\":{\r"
			if(useZmrkNum) // Make an array of marker types and an array of marker fill colors
				string MrkNumZwave = ""
				string MRK_Array = ""
				string MRK_RGBArray = ""
				MrkNumZwave = StringByKey("zmrkNum(x)", info, "=", ";", 1) // We know we have a marker number wave. Extract it by key
				MrkNumZwave = MrkNumZwave[1, strlen(MrkNumZwave) - 2] // strip off the { and }
				AssignMarkerNameArray(MrkNumZwave, MRK_Array, MRK_RGBArray, TraceRGB, UseZColor, RGB_Array, opaque) // Make arrays for color and symbol
				obj += "\"symbol\":" + Mrk_Array + ",\r"
				obj += "\"color\":" + Mrk_RGBArray + ",\r"
			else // Just one marker type
				PlyMrkr = AssignMarkerName( GetNumFromModifyStr(info, "marker", "", 0), mFill)	// Function to assign marker name
				obj += "\"symbol\":\"" + PlyMrkr + "\",\r" // Marker symbol
				if(MFill == 0 && !opaque) // this is an non-filled marker type and not opaque
					obj += "\"color\":\"rgba(0,0,0,0)\",\r"
				elseif(MFill == 0 && opaque) // This is a non-filled marker type but it's opaqu (white)
					obj += "\"color\":\"rgb(255,255,255)\",\r"
				elseif(UseZColor) // The marker color is an array
					obj += "\"color\":" + RGB_Array + ",\r"
				else	// The marker is filled-type, and set by the main trace color
					obj += "\"color\":" + TraceRGB + ",\r"
				endif
			endif // End of marker type section
			obj += "\"line\":{\r" // Marker stroke information only for markers, not dots or text
			if(UseMrkrStroke)
				obj += "\"color\":" + MarkerRGB + ",\r"
			elseif(UseZColor) // This is a non-filled marker, and we are using z-color
				obj += "\"color\":" + RGB_Array + ",\r"
			else
				obj += "\"color\":" + TraceRGB + ",\r"
			endif
			obj += "\"width\":" + dub2str(MrkrThick) + "\r},\r" // End of stroke
	    elseif(mode==2) // Igor dots at points
			PlyMrkr = "square"
			MrkrSize = Mrk2Px(GetNumFromModifyStr(info, "lSize", "", 0)/2) // For the dots at points command, the size is the same as the line size
			if(MrkrSize > LargestMarkerSize)
			 	LargestMarkerSize = MrkrSize // But we still need 4/3 to go from pts to px
			 endif
			SizeCode = 1
			obj += "\"marker\":{\r"
			obj += "\"symbol\":\"" + PlyMrkr + "\",\r"
			if(UseZColor)
				obj += "\"color\":" + RGB_Array + ",\r"
			else
				obj += "\"color\":" + TraceRGB + ",\r"
			endif
		else // So we are left with text markers
			string txtInfo = StringByKey("textmarker(x)", info, "=", ";") // Read all the information about the text markers
			string txt
			variable infoPntr // This will be a pointer to keep track of positions in the string as we parse it
			MrkrSize = Txt2Px(MrkrSize) // Text size is 3*marker size
			if(MrkrSize > LargestMarkerSize)
				LargestMarkerSize = MrkrSize
			endif
			SizeCode = 3
			obj += "\"text\":"
			infoPntr = strsearch(txtinfo, ",", 0) // Set a pointer to the place where we find the first comma, after the text.
			if(char2num(txtinfo[1]) == 34) // The graph text is a string, not a wave, CHAR(34) is a quote "
				txt = txtinfo[2, infoPntr-2] // Igor allows strings with up to 3 chars for the text marker. This line pulls out the marker
				Make/T/O/N=(trlen) txtWave = txt
				obj += txtWavetoJSONArray(txtWave)
			else // The text is specified by a wave.
				txt = txtinfo[1, infoPntr - 1] // There are no quotes around the wave name, so move only 1 space back from the comma
				if(WaveType($txt)) // WaveType is 0 for non-numeric waves, so TRUE means we have a numeric wave
					Duplicate/O $txt LocalTxt
					Make/T/O/N=(trlen) txtWave = dub2str(LocalTxt)
					obj += txtWaveToJSONArray(txtWave)
				else
					obj += txtWaveToJSONArray($txt)
				endif
			endif
			obj += ",\r"
			txtinfo = txtinfo[infopntr + 1, inf]
			infopntr = strsearch(txtinfo, ",", 0)
			string txtFont = txtinfo[0, infopntr - 1]
			string txtrgbR, txtrgbG, txtrgbB

			obj += "\"textfont\":{\r"
			obj += "\"family\":" + txtFont + ",\r"
			if(UseMrkrStroke) // if this parameter is 1, the text is different than the main trace color
				obj += "\"color\":" + MarkerRGB + ",\r"
			elseif(useZcolor)
				obj += "\"color\":" + RGB_Array + ",\r"
			else
				obj += "\"color\":" + TraceRGB + ",\r"
			endif
		endif

		if(useZsize && !(SizeCode == 1))
		 	string SizeInfo = StringByKey("zmrkSize(x)", info, "=", ";") // First check for zColor
		 	Sizeinfo = Sizeinfo[1, strlen(Sizeinfo) - 2] // Strip off the { }
		 	Size_Array = zSizeArray(SizeInfo,SizeCode)
		 	obj += "\"size\":" + Size_Array + ",\r"
		elseif(mrkrSize==0) // Check whether the marker size is 0, which means autosize
			obj += "\"size\":" + dub2str(Txt2Px(defaultTextSize)) + ",\r"
		else
			obj += "\"size\":" + dub2str(Txt2Px(2*mrkrSize)) + ",\r"
		endif
		variable mskip = GetNumFromModifyStr(info, "mskip", "", 0)
		if(mskip > 0 && strsearch(plyMode, "lines", 0) > -1) // We only skip markers if there is also a line being drawn.
			variable maxMarkers = trLen / (mskip + 1)
			obj += "\"maxdisplayed\":" + dub2str(maxMarkers) + ",\r"
		endif
		obj = obj[0, strlen(obj) - 3] // Remove comma.
		obj += "\r},\r"
	endif
	// End of Markers

	// Set MODE information
	if(GetNumFromModifyStr(info, "gaps", "", 0)==0)
		obj += "\"connectgaps\":true,\r"
	endif

	obj += "\"name\":\"" + plyName + "\",\r"
	if(mode==5)
		obj += "\"type\":\"bar\",\r"
	else
		obj += "\"type\":\"scatter\",\r"
	endif
	obj += "\"mode\":\"" + plyMode + "\",\r"

	// Set Error bar information
	string EBinfo = StringByKey("ERRORBARS", info, ":", ";", 1)
	if(strlen(EBinfo) > 0) // error bars
		EBinfo = EBinfo[9, strlen(EBinfo)] // Stip out the word Errorbars
		variable EBcapThk = str2num(StringByKey("T", EBInfo, "=", "/"))
		variable EBlineThk = str2num(StringByKey("L", EBInfo, "=", "/"))
		variable EBxW = str2num(StringByKey("X", EBInfo, "=", "/"))
		variable EByW = str2num(StringByKey("Y", EBInfo, "=", "/"))

		variable sp1=strsearch(EBinfo, " ", 0) // We find the first space. After the first space is the trace name
		variable cma1=strsearch(EBinfo, ",", 0) // We find the first comma
		variable sp2=strsearch(EBinfo, " ", cma1, 1) // We find the last space before the comma. After this space is the mode of error bars

		variable PosEndX=0 // This will tell us where the info for the first error bar ends, which we need to know if we need to worry about a second error bar
		string EBmode = EBinfo[sp2 + 1, cma1 - 1]
		string ErSpec1 = EBinfo[cma1, 1] // We only need the first character after the string to figure out what the error specification is. :pct,sqrt, const, wave
		if(StringMatch(ErSpec1, "w") )	 // The first error spec is a wave type
			variable pL = strsearch(EBinfo, "(", cma1)  // find left (
			variable Wcma = strsearch(EbInfo, ",", pL) // find the , between the wave names
			variable pR = strsearch(EBinfo, ")", Wcma)  // find the )
			string pw1 = EBinfo[pL + 1, Wcma - 1] // wave for plus error bar 1
			string mw1 = EBinfo[Wcma + 1, pR - 1] // wave for minus error bar 1
			PosEndX = pR + 1
		else
			variable eq = strsearch(EBinfo, "=", cma1)       // Find the =
			variable cma2 = strsearch(EBinfo, ",", cma1, 1) // Find the ,
			PosEndX=cma2
			if(cma2 < 0)
				cma2 = strlen(EBinfo) + 1
			endif
			string val1 = ebinfo[eq + 1, cma2 - 1]
		endif
		if(StringMatch(EBmode, "X") || StringMatch(EBmode, "XY") || StringMatch(EBmode, "BOX") )
			obj += "\"error_x\":{\r"
			obj += "\"visible\":true,\r"
			obj += "\"color\":"+ TraceRGB + ",\r"
			if(!numtype(EBlineThk)) // Set the line thickness
				obj += "\"thickness\":" + dub2str(EBlineThk) + ",\r"
			else
				obj += "\"thickness\":1,\r"
			endif
			if(!numtype(EByW)) // Set the y-cap width
				obj += "\"width\":" + dub2str(EByW) + ",\r"
				if(LargestMarkerSize < EByW)
					LargestMarkerSize = EByW
				endif
			else
				obj += "\"width\":" + dub2str(defaultMarkerSize) + ",\r"
				if(LargestMarkerSize < defaultMarkerSize)
					LargestMarkerSize = defaultMarkerSize
				endif
			endif
			if(StringMatch(ErSpec1, "w") ) // Wave type errors
				obj += "\"type\":\"data\",\r"
				if(strlen(pw1) > 0)
				 	obj += "\"array\":" + wavetoJSONarray($pw1) + ",\r"
				 else
				 	Make/O/FREE/N=(TrLen) NullEB = 0
				 	obj += "\"array\":" + wavetoJSONarray(NullEB) + ",\r"
				 endif
				if(StringMatch(pw1, mw1))
					obj += "\"symmetric\":true,\r"
				else
					if(strlen(mw1) > 0)
					 	obj += "\"arrayminus\":" + wavetoJSONarray($mw1) + ",\r"
					 else
					 	Make/O/FREE/N=(TrLen) NullEB = 0
					 	obj += "\"array\":" + wavetoJSONarray(NullEB) + ",\r"
					 endif
				endif
			elseif(StringMatch(ErSpec1, "p")) // percent type errors
				obj += "\"type\":\"percent\",\r"
				obj += "\"value\":" + val1 + ",\r"
				obj += "\"symmetric\":true,\r"
			elseif(StringMatch(ErSpec1, "s")) // sqrt type errors
				obj += "\"type\":\"sqrt\",\r"
				obj += "\"symmetric\":true,\r"
			else // constant type errors
				obj += "\"type\":\"constant\",\r"
				obj += "\"value\":" + val1 + ",\r"
				obj += "\"symmetric\":true,\r"
			endif
			obj = obj[0, strlen(obj) - 3] // Remove comma.
			obj += "\r},\r"	// End of the X-section when there area x AND y error bars
			EBinfo = EBinfo[PosEndx + 1, strlen(EBinfo)] // Strip off the EB info we've already extracted so we can extract more
			if(StringMatch(EBMode, "XY") || StringMatch(EBmode, "BOX") ) // These two modes have a second error bar to deal with which requires more string-scanning. 
				// BOX isn't supported in Plotly, so we just to regular error bars as a kludge
				obj += "\"error_y\":{\r"
				obj += "\"visible\":true,\r"
				obj += "\"color\":"+ TraceRGB + ",\r"
				if(!numtype(EBlineThk)) // Set the line thickness
					obj += "\"thickness\":" + dub2str(EBlineThk) + ",\r"
				else
					obj += "\"thickness\":1,\r"
				endif
				if(!numtype(EByW)) // Set the y-cap width
					obj += "\"width\":" + dub2str(EByW) + ",\r"
					if(LargestMarkerSize < EByW)
						LargestMarkerSize = EByW
					endif
				else
					obj += "\"width\":" + dub2str(defaultMarkerSize) + ",\r"
					if(LargestMarkerSize < defaultMarkerSize)
						LargestMarkerSize = defaultMarkerSize
					endif
			endif
				// Now we have to parse through the EB info again
				string ErSpec2 = EBinfo[0] // We only need the first character after the string to figure out what the error specification is. :pct,sqrt, const, wave
				if(StringMatch(ErSpec2, "w") )	// The first error spec is a wave type
					pL = strsearch(EBinfo, "(", 0) // find left (
					Wcma = strsearch(EbInfo, ",", pL) // find the , between the wave names
					pR = strsearch(EBinfo, ")", Wcma) // find the )
					pw1 = EBinfo[pL + 1, Wcma - 1] // Wave for plus error bar 1
					mw1 = EBinfo[Wcma + 1, pR - 1] // wave for minus error bar 1
				else
					eq = strsearch(EBinfo, "=", 0) // Find the =
					cma2 = strsearch(EBinfo, ",", 0) 		// find the ,
					if(cma2 < 0)
						cma2 = strlen(EBinfo) + 1
					endif
					val1 = ebinfo[eq + 1, cma2 - 1]
				endif

				if(StringMatch(ErSpec2, "w") ) // Wave type errors
					obj += "\"type\":\"data\",\r"
					if(strlen(pw1) > 0)
					 	obj += "\"array\":" + wavetoJSONarray($pw1) + ",\r"
					 else
					 	Make/O/FREE/N=(TrLen) NullEB = 0
					 	obj += "\"array\":" + wavetoJSONarray(NullEB) + ",\r"
					 endif
					if(StringMatch(pw1, mw1))
						obj += "\"symmetric\":true,\r"
					else
						if(strlen(mw1) > 0)
						 	obj += "\"arrayminus\":" + wavetoJSONarray($mw1) + ",\r"
						 else
						 	Make/O/FREE/N=(TrLen) NullEB = 0
						 	obj += "\"array\":" + wavetoJSONarray(NullEB) + ",\r"
						 endif
					endif
				elseif(StringMatch(ErSpec2, "p")) // percent type errors
					obj += "\"type\":\"percent\",\r"
					obj += "\"value\":" + val1 + ",\r"
					obj += "\"symmetric\":true,\r"
				elseif(StringMatch(ErSpec2, "s")) // sqrt type errors
					obj += "\"type\":\"sqrt\",\r"
					obj += "\"symmetric\":true,\r"
				else // constant type errors
						obj += "\"type\":\"constant\",\r"
					obj += "\"value\":" + val1 + ",\r"
					obj += "\"symmetric\":true,\r"
				endif
				obj = obj[0, strlen(obj) - 3] // Remove comma.
				obj += "\r},\r"
			endif // End of handling x, y error bars

		else // End of x-error bar section. if we are here, it means we have ONLY y-error bars
			obj += "\"error_y\":{\r"
			obj += "\"visible\":true,\r"
			obj += "\"color\":" + TraceRGB  + ",\r"
			if(!numtype(EBlineThk)) // Set the line thickness
					obj += "\"thickness\":" + dub2str(EBlineThk) + ",\r"
				else
					obj += "\"thickness\":1,\r"
				endif
				if(!numtype(EByW)) // Set the y-cap width
					obj += "\"width\":" + dub2str(EByW) + ",\r"
					if(LargestMarkerSize < EByW)
						LargestMarkerSize = EByW
					endif
				else
					obj += "\"width\":" + dub2str(defaultMarkerSize) + ",\r"
					if(LargestMarkerSize < defaultMarkerSize)
						LargestMarkerSize = defaultMarkerSize
					endif
			endif
			if(StringMatch(ErSpec1, "w") ) // Wave type errors
				obj += "\"type\":\"data\",\r"
				if(strlen(pw1) > 0)
				 	obj += "\"array\":" + wavetoJSONarray($pw1) + ",\r"
				 else
				 	Make/O/FREE/N=(TrLen) NullEB = 0
				 	obj += "\"array\":" + wavetoJSONarray(NullEB) + ",\r"
				 endif
				if(StringMatch(pw1, mw1))
					obj += "\"symmetric\":true,\r"
				else
					if(strlen(mw1) > 0)
					 	obj += "\"arrayminus\":" + wavetoJSONarray($mw1) + ",\r"
					 else
					 	Make/O/FREE/N=(TrLen) NullEB = 0
					 	obj += "\"array\":" + wavetoJSONarray(NullEB) + ",\r"
					 endif
				endif
			elseif(StringMatch(ErSpec1, "p")) // percent type errors
				obj += "\"type\":\"percent\",\r"
				obj += "\"value\":" + val1 + ",\r"
				obj += "\"symmetric\":true,\r"
			elseif(StringMatch(ErSpec1, "s")) // sqrt type errors
				obj += "\"type\":\"sqrt\",\r"
				obj += "\"symmetric\":true,\r"
			else // constant type errors
				obj += "\"type\":\"constant\",\r"
				obj += "\"value\":" + val1 + ",\r"
				obj += "\"symmetric\":true,\r"
			endif
			obj = obj[0, strlen(obj) - 3] // Remove comma.
			obj += "\r},\r"
		endif // End of ONLY y-error bar section
	endif
	// End error bars

	if(GetNumFromModifyStr(info, "hideTrace", "", 0))
		obj += "\"visible\":false,\r"
	endif
	obj = obj[0, strlen(obj) - 3] // Remove comma.
	obj += "\r}"
	return obj
End

// Returns the domain of the anchor axis as pointers
static Function ReadAchorDomain(graph, anchorAx, anchorDlo, anchorDhi)
	string graph, anchorAx
	variable &anchorDlo, &anchorDhi

	string info = AxisInfo(graph, anchorAx)
	anchorDLo = GetNumFromModifyStr(info, "axisEnab", "{", 0)
	anchorDHi = GetNumFromModifyStr(info, "axisEnab", "{", 1)
End

static Function/T createAxisObj(axisName, PlyAxisName, graph, Orient, AxisNum)
	string axisName, PlyAxisName, graph, orient
	variable AxisNum

	string obj = "\"" + plyAxisName + "\" : {\r"
	string info = AxisInfo(graph, axisName)
	SVAR HaxisList = root:Packages:Plotly:HAxisList
	SVAR VaxisList = root:Packages:Plotly:VAxisList
	NVAR sizeMode = root:Packages:Plotly:sizeMode
	NVAR defaultTickLength = root:Packages:Plotly:defaultTickLength
	NVAR defaultMarkerSize = root:Packages:Plotly:defaultMarkerSize // In Igor size, not points		
	NVAR LargestMarkerSize = root:Packages:Plotly:LargestMarkerSize // In Igor size, not points			
	NVAR Standoff = root:Packages:Plotly:Standoff
	NVAR HL =root:Packages:Plotly:HL
	NVAR HR =root:Packages:Plotly:HR
	NVAR VT =root:Packages:Plotly:VT
	NVAR VB =root:Packages:Plotly:VB
	NVAR catGap = root:Packages:Plotly:catGap
	NVAR barGap = root:Packages:Plotly:barGap
	SVAR BarToMode = root:packages:Plotly:BarToMode
	NVAR catCount = root:packages:Plotly:CatCount
	variable rgbR
	variable rgbG
	variable rgbB

	string XAxis = StringByKey("XAXIS", info, ":", ";", 1) // Get the name of the x-axis
	string YAxis = StringByKey("YAXIS", info, ":", ";", 1) // Get the name of the y-axis

	string AxisFlags = StringByKey("AXFLAG", info, ":", ";", 1)
	string Lnam = StringByKey("L", AxisFlags, "=", "/", 1)
	string Tnam = StringByKey("T", AxisFlags, "=", "/", 1)
	string Rnam = StringByKey("R", AxisFlags, "=", "/", 1)
	string Bnam = StringByKey("B", AxisFlags, "=", "/", 1)
	variable FreeLo, FreeHi, pxSize, FreeNumPerPx, FreeFrac
	variable domainLow = GetNumFromModifyStr(info, "axisEnab", "{", 0)
	variable domainHigh = GetNumFromModifyStr(info, "axisEnab", "{", 1)
	obj += "\"domain\" : [" + dub2str(domainLow) + "," + dub2str(domainHigh) + "],\r" // Set the axis domain


	variable AnchorData
	string AnchorAx
	variable FreeIndex = strsearch(info, "freePos", 0) // Read to see if there is a free axis here
	variable cma, curly
	variable RorT
	if(StringMatch(orient, "H")) // Horizontal axis...figure out top or bottom
		if(StringMatch(axisname, "bottom") || strlen(Bnam) > 0)
			obj += "\"side\":\"bottom\",\r"
			RorT = 0 // Set a flag if this is a right or top axis
		else
			obj += "\"side\":\"top\",\r"
			RorT = 1
		endif
		// Free axis calculations for Horizontal axes-----------------------------------------------------------------------------
		if(FreeIndex > -1) // this is a free axis if true
			if(StringMatch(info[Freeindex , 11], "{")) 	// We have to read a number and an axis name
				cma = strsearch(info, ",", freeindex + 11)
				curly = strsearch(info, "}", cma)
				AnchorData = str2num(info[FreeIndex + 12, cma - 1])
				AnchorAx = info[cma + 1, curly - 1]
				if(StringMatch(anchorAx, "kwFraction") ) // This is a fraction of the graph area...Plotly native!
					obj += "\"anchor\":\"free\",\r"
					obj += "\"position\":" + num2str(AnchorData) + ",\r"
				else // The free axis is specified against a vertical axis in Igor, so now we need to calculate
					GetWindow $graph, psizeDC // Look up the plot px dimensions
					pxSize = V_bottom - V_top // The pixel size of the plot area
					Getaxis/W=$Graph/Q $anchorAx // get the igor range of the axis we're anchoring to
					FreeNumPerPX= abs(V_min-V_max)/pxSize
					FreeLo = V_min // - (LargestMarkerSize*2.25)*FreeNumperPx  // if changed, also need to change the axis scaling section. Complicated because of standoff
					FreeHi = V_max // + (LargestMarkerSize*2.25)*FreeNumPerPx
					variable anchorDlo=0 // variables to store the domain range of the crossing axis
					variable anchorDhi=1
					ReadAchorDomain(graph, anchorAx, anchorDlo, anchorDhi) // Returns the domain of the anchor axis as pointers
					FreeFrac = anchorDlo + (anchorDhi - anchorDlo) * (AnchorData - FreeLo) / (FreeHi - FreeLo)
					obj +="\"anchor\":\"free\",\r"
					obj +="\"position\":" + dub2str(FreeFrac) + ",\r"
				endif
			else //'Just" have to read a pixel number
				GetWindow $graph, psize // Look up the plot pt dimensions
				pxSize = V_bottom - V_top // The POINT size of the plot area
				cma = strsearch(info, ";", freeIndex + 11) // Actually a semicolon...
				AnchorData = str2num(info[FreeIndex + 11, cma - 1]) // Read the position of the axis supposedly in points from the bottom axis
				FreeFrac = -(AnchorData/PxSize)
				obj +="\"anchor\":\"free\",\r"
				if(RorT) // Have to go from the other margin if Right or Top
					obj += "\"position\":" + dub2str(1 - FreeFrac) + ",\r"
				else
					obj += "\"position\":" + dub2str(FreeFrac) + ",\r"
				endif
			endif
		endif // Not a free axis, so do nothing
	else // Vertical axis
		if(StringMatch(axisname, "left") || strlen(Lnam) > 0)
			obj += "\"side\":\"left\",\r"
			RorT = 0
		else
			obj += "\"side\":\"right\",\r"
			RorT = 1
		endif
		// Freee Axis for verticle
		if(FreeIndex > -1) // this is a free axis if true
			if(StringMatch(info[Freeindex + 11], "{")) 	// We have to read a number and an axis name
				cma = strsearch(info, ",", freeindex + 11)
				curly = strsearch(info, "}", cma)
				AnchorData = str2num(info[FreeIndex + 12, cma - 1])
				AnchorAx = info[cma + 1, curly - 1]
				if(StringMatch(anchorAx, "kwFraction") ) // This is a fraction of the graph area...Plotly native!
					obj += "\"anchor\":\"free\",\r"
					obj += "\"position\":" + num2str(AnchorData) + ",\r"
				else // The free axis is specified against a vertical axis in Igor, so now we need to calculate :(
					GetWindow $graph, psizeDC // Look up the plot px dimensions
					pxSize = V_right - V_left // The pixel size of the plot area
					Getaxis/W=$Graph/Q $anchorAx // get the igor range of the axis we're anchoring to
					FreeNumPerPX = abs(V_min - V_max) / pxSize
					FreeLo = V_min // - (LargestMarkerSize * 2.25) * FreeNumperPx  // if changed, also need to change the axis scaling section
					FreeHi = V_max // + (LargestMarkerSize * 2.25) * FreeNumPerPx
					ReadAchorDomain(graph, anchorAx, anchorDlo, anchorDhi) // Returns the domain of the anchor axis as pointers
					FreeFrac = anchorDlo + (anchorDhi - anchorDlo) * (AnchorData - FreeLo) / (FreeHi - FreeLo)
					obj += "\"anchor\":\"free\",\r"
					obj += "\"position\":" + dub2str(FreeFrac) + ",\r"
				endif
			else // Just have to read a pixel number
				GetWindow $graph, psize // Look up the plot pt dimensions
				pxSize = V_right - V_left // The POINT size of the plot area
				cma = strsearch(info, ";", freeIndex, 11) // Actually a semicolon...
				AnchorData = str2num(info[FreeIndex + 11, cma - 1]) // Read the position of the axis supposedly in points from the bottom axis
				FreeFrac = -(AnchorData/PxSize)
				obj += "\"anchor\":\"free\",\r"
				if(RorT) // Have to go from the other margin if Right or Top
					obj += "\"position\":" + dub2str(1 - FreeFrac) + ",\r"
				else
					obj += "\"position\":" + dub2str(FreeFrac) + ",\r"
				endif
			endif
		endif // Not a free axis, so do nothing
	endif

	string defaultFnt = GetDefaultFont(graph)
	variable defaultTextSizePT = GetDefaultFontSize(graph, "") // This number is returned in POINTS

	// Axis Label/Title
	string LblTxt = AxisLabelText(graph, axisName, SuppressEscaping=1)
	string altFont
	variable altFontSize, OZ
	LblTxt = ProcessText(LblTxt, altFont, altFontsize, OZ)
	obj += "\"title\":\"" + LblTxt + "\",\r"
	obj += "\"titlefont\":{\r"
	if(!StringMatch(altFont, "default"))
		obj += "\"family\":\"" + altFont + "\",\r"
	endif
	if(AltFontSize > 0)
		obj += "\"size\":" + num2str(txt2px(AltFontSize)) + ",\r"
	endif
	rgbR = round(GetNumFromModifyStr(info, "alblRGB", "(", 0) / 257)
	rgbG = round(GetNumFromModifyStr(info, "alblRGB", "(", 1) / 257)
	rgbB = round(GetNumFromModifyStr(info, "alblRGB", "(", 2) / 257)
	obj += "\"color\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\"\r"
	obj += "},\r"

	// Axis visuals
	rgbR = round(GetNumFromModifyStr(info, "axRGB", "(", 0) / 257)
	rgbG = round(GetNumFromModifyStr(info, "axRGB", "(", 1) / 257)
	rgbB = round(GetNumFromModifyStr(info, "axRGB", "(", 2) / 257)
	obj += "\"linecolor\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"
	variable axThick = GetNumFromModifyStr(info, "axThick", "", 0)
	if(axThick > 0)
		obj += "\"showline\" : true,\r"
		obj += "\"linewidth\" :" + dub2str(ceil(axThick)) + ",\r"
	else
		obj += "\"showline\" : false,\r"
	endif
	variable zero = GetNumFromModifyStr(info, "zero", "", 0)
	variable zeroThick = GetNumFromModifyStr(info, "zeroThick", "", 0)
	if(zero) // Show the zero line
		obj += "\"zeroline\" : true,\r"
		obj += "\"zerolinecolor\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r" // Same color as the axis, I'm afraid
		if(zeroThick)
			obj += "\"zerolinewidth\" : " + dub2str(ZeroThick) + ",\r"
		else
			obj += "\"zerolinewidth\" : " + dub2str(axThick) + ",\r"
		endif
	else
		obj += "\"zeroline\" : false,\r"
	endif
	// Mirror : "true", "ticks", "false", "all", "all, ticks"
	variable mirror = GetNumFromModifyStr(info, "mirror", "", 0)
	if(mirror == 1)
		obj += "\"mirror\" : \"ticks\",\r"
	elseif(mirror == 2)
		obj += "\"mirror\" : true,\r"
	elseif(mirror == 3)
		obj += "\"mirror\" : \"all, ticks\",\r"
	else
		obj += "\"mirror\" : false,\r"
	endif
	variable grid = GetNumFromModifyStr(info, "grid", "", 0)
	if(grid)
		rgbR = round(GetNumFromModifyStr(info, "gridRGB", "(", 0) / 257)
		rgbG = round(GetNumFromModifyStr(info, "gridRGB", "(", 1) / 257)
		rgbB = round(GetNumFromModifyStr(info, "gridRGB", "(", 2) / 257)
		obj += "\"showgrid\": true,\r"
		obj += "\"gridcolor\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"
	else
		obj += "\"showgrid\": false,\r"
	endif

	// Tick Visuals
	variable btThick = GetNumFromModifyStr(info, "btThick", "", 0)
	if(btThick == 0 )
		btThick = axThick
	endif
	obj += "\"tickwidth\":" + num2str(btThick) + ",\r"
	obj += "\"tickcolor\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r" // Same as axis color
	obj += "\"tickfont\":{\r"
	rgbR = round(GetNumFromModifyStr(info, "tlblRGB", "(", 0)/257)
	rgbG = round(GetNumFromModifyStr(info, "tlblRGB", "(", 1)/257)
	rgbB = round(GetNumFromModifyStr(info, "tlblRGB", "(", 2)/257)
	obj += "\"color\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\"\r"
	obj += "},\r"

	variable btLen = GetNumFromModifyStr(info, "btLen", "", 0)
	if(btLen == 0)
		btLen = defaultTickLength
	endif
	obj += "\"ticklen\":" + num2str(btLen) + ",\r"
	variable tickType = GetNumFromModifyStr(info, "tick", "", 0)
	if(tickType == 0)
		obj += "\"ticks\" : \"outside\",\r"
	elseif(tickType == 1) // Crossing axes...not sure what to do, not supported by Plotly
		obj += "\"ticks\" : \"crossing\",\r"
		print "WARNING: Crossing ticks not supported by Plotly"
	elseif(tickType == 2)
		obj += "\"ticks\" : \"inside\",\r"
	else
		obj += "\"ticks\" : \"\",\r"
	endif
	variable noLabel = GetNumFromModifyStr(info, "noLabel", "", 0) // Decide whether to show tick labels
	if(noLabel == 1 || noLabel == 2)
		obj += "\"showticklabels\":false,\r"
	endif
	// Axis Range and axis side assignment This is complicated because of the need to do standoff.
	Getaxis/W=$Graph/Q $axisName // get the igor range
	variable IgLo = V_min
	variable IgHi = V_max
	variable PlyLo
	variable PlyHi
	GetWindow $graph, psizeDC // Look up the plot px dimensions
	variable pheight = V_bottom - V_top
	variable pwidth = V_right - V_left
	variable p_bottom = V_bottom
	variable p_top = V_top
	variable p_left = V_left
	variable p_right = V_right
	variable numPerpx

	variable IsLog= GetNumFromModifyStr(info, "log", "", 0)
	if(StringMatch(orient, "H") && !isLog) // can't do simple standoff calc on log axis
		NumPerPX= abs(IgLo-IgHi)/pwidth
		PlyLo = IgLo - (LargestMarkerSize * 2.25) * NumPerPx // if you change this, also need to take care of Free axis section. Changed from /1.25 to *1.25 because of apparent marker size change
		PlyHi = IgHi + (LargestMarkerSize * 2.25) * NumPerPx
	elseif(StringMatch(orient, "H"))
		NumPerPx = (abs(log(IgLo))-abs(log(IgHi)))/pwidth
		PlyLo = log(IgLo) - (LargestMarkerSize * 2.25) * NumPerPx
		PlyHi = log(IgHi) + (LargestMarkerSize * 2.25) * NumPerPx
	endif
	if(StringMatch(orient, "V")&& !isLog) // Can't do simple standoff calc on log axis
		NumPerPX = abs(IgLo-IgHi) / pheight
		PlyLo = IgLo - (LargestMarkerSize * 2.25) * NumPerPx
		PlyHi = IgHi + (LargestMarkerSize * 2.25) * NumPerPx
	elseif(StringMatch(orient, "V"))
		NumPerPx = (abs(log(IgLo)) - abs(log(IgHi))) / pheight
		PlyLo = log(IgLo) - (LargestMarkerSize * 2.25) * NumPerPx
		PlyHi = log(IgHi) + (LargestMarkerSize * 2.25) * NumPerPx
	endif

	variable IsCat = NumberByKey("ISCAT", info, ":", ";", 0)
	if(IsCat)
		obj += "\"type\": \"catgory\",\r"
		catGap = GetNumFromModifyStr(info, "catGap", "", 0) // Save these in the global list for use in the global section of KWARGS
		barGap = GetNumFromModifyStr(info, "barGap", "", 0)
		if(PlyLo > -0.5) // We need to adjust for plotly category plots, they go to -.5. But we allow for intentionally MORE negative ranges...
			PlyLo = -0.5
		endif
		if(PlyHi == CatCount)
			PlyHi = catCount - 0.5
		endif
	elseif(IsLog)
		obj += "\"type\": \"log\",\r"
	else
		obj += "\"type\": \"linear\",\r"
	endif
	obj += "\"exponentformat\":\"power\",\r"
	obj += "\"range\": [" + dub2str(PlyLo) + "," + dub2str(PlyHi) + "],\r"

	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r"
	return (Obj)
End


static Function/T AnchorText(A)
	string A
	string obj = ""
	if(strsearch(A, "L", 0) > -1)
		obj += "\"xanchor\":\"left\",\r"
	elseif(strsearch(A, "M", 0) > -1)
		obj += "\"xanchor\":\"center\",\r"
	elseif(strsearch(A, "R", 0) > -1)
		obj += "\"xanchor\":\"right\",\r"
	endif
	if(strsearch(A, "T", 0) > -1)
		obj += "\"yanchor\":\"top\",\r"
	elseif(strsearch(A, "C", 0) > -1)
		obj += "\"yanchor\":\"middle\",\r"
	elseif(strsearch(A, "B", 0) > -1)
		obj += "\"yanchor\":\"bottom\",\r"
	endif
	return obj
End

Function ReadWaveAxes(graph, yw, PlyYaxName, PlyXaxName)
	string graph, yw, &PlyYaxName, &PlyXaxName
	string info = traceinfo(graph, yw, 0)
	SVAR HaxisList = root:Packages:Plotly:HAxisList
	SVAR VaxisList = root:Packages:Plotly:VAxisList
	string xax = StringByKey("XAXIS", info, ":", ";", 1)
	string yax = StringByKey("YAXIS", info, ":", ";", 1)
	string Hax, Vax
	variable foundH = 0
	variable foundV = 0
	variable i=0
	do
		Hax = StringFromList(i, Haxislist, ";")
		Vax = StringFromList(i, Vaxislist, ";")
		if(StringMatch(Hax, "") && StringMatch(Vax, ""))
			break
		endif
		if(StringMatch(xax, Hax) || StringMatch(yax, Hax))
			PlyXaxName = "x" + num2str(i + 1)
			foundH = 1
		endif
		if(StringMatch(xax, Vax) || StringMatch(yax, Vax))
			PlyYaxName = "y" + num2str(i + 1)
			foundV = 1
		endif
		i += 1
	while ((FoundH == 0) || (FoundV == 0))
End

static Function/T CreateAnnotationObj(Name, graph)
	string name, graph
	string info = annotationinfo(graph, name, 1)
	string Type = StringByKey("TYPE", info, ":", ";", 1)
	string obj = ""
	string Flags = StringByKey("FLAGS", info, ":", ";", 1)
	string anchorCode, backCode, dflag, TxtColor, exterior, text
	variable absX, absY, fracx, fracy, Xpos, Ypos, xOff, yOff, Rotation

	GetWindow $graph, gsize // Look up the size of the graph window, in points
	variable g_left = V_left
	variable g_right = V_right
	variable g_top = V_top
	variable g_bottom = V_bottom
	GetWindow $graph, psize // look up the plot size in points
	variable p_left = V_left
	variable p_right = V_right
	variable p_top = V_top
	variable p_bottom = V_bottom
	variable rgbR, rgbG, rgbB, rgbA, frame

	// In Igor size, not points
	NVAR defaultMarkerSize = root:Packages:Plotly:defaultMarkerSize

	if(StringMatch(type, "Legend") || StringMatch(type, "ColorScale") ) // Get the legend object started.
		return ""
	elseif(StringMatch(type, "Tag" )) // Do the tag-specific things first, then to generic annotation things later-----------------------------------------------
		variable line = PLYParseTagForLine(graph, name)
		obj += "{\r"

		xOff = str2num(StringByKey("X", flags, "=", "/", 1)) / 100
		yOff = str2num(StringByKey("Y", flags, "=", "/", 1)) / 100
		if(line == 0 || (xOff == 0 && yOff == 0))
			obj += "\"showarrow\":false,\r"
		elseif(line == 1)
			obj += "\"showarrow\":true,\r"
			obj += "\"arrowhead\":0,\r"
		else
			obj += "\"showarrow\":true,\r"
			obj += "\"arrowhead\":3,\r"
		endif
		obj += "\"arrowwidth\":1,\r"
		obj += "\"arrowsize\":" + dub2str(ceil(defaultmarkersize/5)) + ",\r" /// This arrow size gives a good guess to the way Igor autoscales the arrow.

		variable ax = (xOff * (p_right - p_left)) * ScreenResolution / 72
		variable ay = (yOff * (p_top - p_bottom)) * ScreenResolution / 72
		variable attachx = str2num(StringByKey("ATTACHX", info, ":", ";", 1))
		string yw = StringByKey("YWAVE", info, ":", ";", 1)
		string ywf = StringByKey("YWAVEDF", info, ";", ";", 1)
		string xw = StringByKey("XWAVE", info, ":", ";", 1)
		string xwf = StringByKey("XWAVEDF", info, ";", ";", 1)
		wave ywave = tracenametowaveref(graph, yw)
		yPos = ywave(attachx)
		if(!StringMatch(xw, "") )
			wave xwave = xwavereffromtrace(graph, yw)
			variable pnt = x2pnt(ywave, attachx)
			xPos = xwave[pnt]
		else
			xPos = attachx
		endif
		string PlyXaxName=""
		string PlyYaxName=""
		ReadWaveAxes(graph, yw, PlyYaxName, PlyXaxName)
		obj += "\"xref\":\"" + PlyXaxName + "\",\r"
		obj += "\"yref\":\"" + PlyYaxName + "\",\r"
		obj += "\"x\":" + dub2str(xPos) + ",\r"
		obj += "\"y\":" + dub2str(yPos) + ",\r"
		obj += "\"ax\":" + dub2str(ax) + ",\r"
		obj += "\"ay\":" + dub2str(ay) + ",\r"
		string LblTxt = StringByKey("TEXT", info, ":", ";", 1)
		string altFont
		variable altFontSize, OZ
		variable num = 0
		if(strsearch(lbltxt, "\OZ", 0) > -1) // this is an auto text equal to the z-value of a contour.
			variable pos = strsearch(yw, "=", 0)
			string temp = yw[pos + 1, strlen(yw) - 1]
			num = str2num(temp)
			lbltxt = num2str(num)
		endif

		LblTxt = ProcessText(LblTxt, altFont, altFontsize, OZ, OZval=num) // For tags, there is a possibility that we have an /OZ flag, so we need to send the trace name
		obj += "\"text\":\"" + LblTxt + "\",\r"
	else // text box-specific things
		obj += "{\r"
		obj += "\"showarrow\":false,\r"
		obj += "\"xref\":\"paper\",\r"
		obj += "\"yref\":\"paper\",\r"
		absx = str2num(StringByKey("ABSX", info, ":", ";", 1))
		absy = str2num(StringByKey("ABSY", info, ":", ";", 1))
		fracx = (absx-p_left)/(p_right-p_left)
		fracy = (absy-p_bottom)/(p_top-p_bottom)
		obj += "\"x\":" + dub2str(fracx) + ",\r"
		obj += "\"y\":" + dub2str(fracy) + ",\r"
		LblTxt = StringByKey("TEXT", info, ":", ";", 1)
		LblTxt = ProcessText(LblTxt, altFont, altFontsize, OZ)
		obj += "\"text\":\"" + LblTxt + "\",\r"
	endif

	// generic section

	anchorcode = StringByKey("A", flags, "=", "/", 1)
	backCode = StringByKey("B", flags, "=", "/", 1)
	dflag = StringByKey("D", flags, "=", "/", 1)
	exterior = StringByKey("E", flags, "=", "/", 1)
	frame = str2num(StringByKey("F", flags, "=", "/", 1))
	Rotation = str2num(StringByKey("O", flags, "=", "/", 1))
	txtColor = "txtcolor(x)="+StringByKey("G", flags, "=", "/", 1) // prepend a string used to search in the standard way

	if(!(Rotation == 0))
		obj += "\"textangle\":" + num2str(-Rotation) + ",\r"
	endif
	obj += AnchorText(anchorcode)
	if(frame == 2) // border
		if(strsearch(dflag, "{", 0) > -1) // fancy flag: take just thefirst number, the actual borderwidth
			dflag = "dflag(x)=" + dflag
			dflag = dub2str(GetNumFromModifyStr(dflag, "dflag", "{", 0))
		endif
	elseif(frame == 0) // no border
		dflag = "0"
	endif
	obj += "\"borderwidth\":" + dflag + ",\r"

	if(StringMatch(backCode[0], "(")) // The background code is a color
		backCode = "bgcolor(x)=" + backCode // Add a key for the standard format for the key searcher
		rgbR = round(GetNumFromModifyStr(backCode, "bgcolor", "(", 0)/257)
		rgbG = round(GetNumFromModifyStr(backCode, "bgcolor", "(", 1)/257)
		rgbB = round(GetNumFromModifyStr(backCode, "bgcolor", "(", 2)/257)
		rgbA = 1
	elseif(str2num(backCode) == 1 ) // transparent background
		rgbR = 0
		rgbG = 0
		rgbB = 0
		rgbA = 0
	elseif(str2num(backCode) == 2 ) // graph area color
		WMGetGraphPlotBkgColor(graph, rgbR, rgbG, rgbB)
		rgbR = round(rgbR / 257)
		rgbG = round(rgbG / 257)
		rgbB = round(rgbB / 257)
		rgbA=1
	endif

	obj += "\"bgcolor\":\"rgba(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + "," + dub2str(rgbA) + ")\",\r"
	string defaultFnt = GetDefaultFont(graph)
	variable defaultTextSizePT = GetDefaultFontSize(graph, "") // This number is returned in POINTS

	// TEXT
	rgbR = round(GetNumFromModifyStr(txtcolor, "txtcolor", "(", 0) / 257)
	rgbG = round(GetNumFromModifyStr(txtcolor, "txtcolor", "(", 1) / 257)
	rgbB = round(GetNumFromModifyStr(txtcolor, "txtcolor", "(", 2) / 257)

	obj += "\"font\":{\r"
	obj += "\"color\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"
	if(!StringMatch(altFont, "default"))
		obj += "\"family\":\"" + altFont + "\",\r"
	endif
	if(AltFontSize > 0)
		obj += "\"size\":" + num2str(txt2px(AltFontSize)) + ",\r"
	endif
	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r"
	obj += "\"bordercolor\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"

	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r"
	return obj
End

// Workaround Igor bug: line information not returned in annotationInfo! Have to parse recreation macro
// @todo investigate if bug is present in IP8
static Function PLYParseTagForLine(win, name)
	string win, name

	string key = "Tag/C/N=" + name
	string commands = WinRecreation(win, 4)
	variable start

	start = strsearch(commands, key, 0)
	if(start > 0)
		variable last = strsearch(commands, "/L=", start)
		if(last > start )
			variable cma = strsearch(commands, "/", last + 1)
			variable spc = strsearch(commands, " ", last + 1)
			variable finish
			if(cma < 0)
				finish = spc
			elseif(spc < 0)
				finish = cma
			else
				finish = min(spc, cma)
			endif
			string Line = commands[last + 3, finish] // "65535, 65534, 49151"
			return str2num(Line)
		endif
	endif

	return 2 // The defualt tag is an arrow.
End

static Function/T CreateLegendObj(Name, graph, IsLegend)
	string name, graph
	variable &isLegend // Set this flag to 1 if we Make a legend, because otherwise we need to disable the legend in the plotly graph, which is on by default.
	string info = annotationinfo(graph, name, 1)
	string Type = StringByKey("TYPE", info, ":", ";", 1)
	string obj = ""
	string Flags = StringByKey("FLAGS", info, ":", ";", 1)
	string anchorCode, backCode, dflag, TxtColor, Rotation, exterior, Xpos, Ypos
	variable absX, absY, fracx, fracy

	GetWindow $graph, gsize // Look up the size of the graph window, in points
	variable g_left = V_left
	variable g_right = V_right
	variable g_top = V_top
	variable g_bottom = V_bottom
	GetWindow $graph, psize // look up the plot size in points
	variable p_left = V_left
	variable p_right = V_right
	variable p_top = V_top
	variable p_bottom = V_bottom
	variable rgbR, rgbG, rgbB, rgbA, frame

	if(StringMatch(type, "Legend") ) // Get the legend object started.
		islegend = 1 // Set the legend flag
		obj += "\"legend\":{\r"
	else
		return ""
	endif

	anchorcode = StringByKey("A", flags, "=", "/", 1)
	backCode = StringByKey("B", flags, "=", "/", 1)
	dflag = StringByKey("D", flags, "=", "/", 1)
	exterior = StringByKey("E", flags, "=", "/", 1)
	frame = str2num(StringByKey("F", flags, "=", "/", 1))
	txtColor = "txtcolor(x)="+StringByKey("G", flags, "=", "/", 1) // prepend a string used to search in the standard way
	xPos = StringByKey("X", flags, "=", "/", 1)
	yPos = StringByKey("Y", flags, "=", "/", 1)
	absx = str2num(StringByKey("ABSX", info, ":", ";", 1))
	absy = str2num(StringByKey("ABSY", info, ":", ";", 1))
	fracx = (absx - p_left) / (p_right - p_left)
	fracy = (absy - p_bottom) / (p_top - p_bottom)
	obj += "\"x\":" + dub2str(fracx) + ",\r"
	obj += "\"y\":" + dub2str(fracy) + ",\r"
	obj += AnchorText(anchorcode)
	if(frame == 2) // border
		if(strsearch(dflag, "{", 0) > -1) // fancy flag: take just thefirst number, the actual borderwidth
			dflag = "dflag(x)=" + dflag
			dflag = dub2str(GetNumFromModifyStr(dflag, "dflag", "{", 0))
		endif
	elseif(frame == 0) // no border
		dflag="0"
	endif
	obj += "\"borderwidth\":" + dflag + ",\r"

	if(StringMatch(backCode[0], "(")) // The background code is a color
		backCode = "bgcolor(x)=" + backCode // Add a key for the standard format for the key searcher
		rgbR = round(GetNumFromModifyStr(backCode, "bgcolor", "(", 0) / 257)
		rgbG = round(GetNumFromModifyStr(backCode, "bgcolor", "(", 1) / 257)
		rgbB = round(GetNumFromModifyStr(backCode, "bgcolor", "(", 2) / 257)
		rgbA = 1
	elseif(str2num(backCode) == 1) // transparent background
		rgbR = 0
		rgbG = 0
		rgbB = 0
		rgbA = 0
	elseif(str2num(backCode) == 2) // Graph area color
		WMGetGraphPlotBkgColor(graph, rgbR, rgbG, rgbB)
		rgbR = round(rgbR/257)
		rgbG = round(rgbG/257)
		rgbB = round(rgbB/257)
	endif
	obj += "\"bgcolor\":\"rgba(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + "," + dub2str(rgbA) + ")\",\r"
	string defaultFnt = GetDefaultFont(graph)
	variable defaultTextSizePT = GetDefaultFontSize(graph, "") // This number is returned in POINTS

	// Axis Label / Title
	rgbR = round(GetNumFromModifyStr(txtcolor, "txtcolor", "(", 0) / 257)
	rgbG = round(GetNumFromModifyStr(txtcolor, "txtcolor", "(", 1) / 257)
	rgbB = round(GetNumFromModifyStr(txtcolor, "txtcolor", "(", 2) / 257)
	string LblTxt = StringByKey("TEXT", info, ":", ";", 1)
	string altFont
	variable altFontSize, OZ
	LblTxt = ProcessText(LblTxt, altFont, altFontsize, OZ)
	obj += "\"text\":\"" + LblTxt + "\",\r"
	obj += "\"font\":{\r"
	obj += "\"color\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"
	if(!StringMatch(altFont, "default"))
		obj += "\"family\":\"" + altFont + "\",\r"
	endif
	if(AltFontSize > 0)
		obj += "\"size\":" + num2str(txt2px(AltFontSize)) + ",\r"
	endif
	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r"
	obj += "\"bordercolor\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"

	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r"
	return obj
End

// Create a Color Scale
static Function/T CreateColorScaleObj(Name, graph, trace)
	string Name, Graph, trace
	string info = annotationinfo(graph, name, 1)
	IgorNB(info + "\r\r")
	string Type = StringByKey("TYPE", info, ":", ";", 1)
	string obj = ""
	string Flags = StringByKey("FLAGS", info, ":", ";", 1)
	string anchorCode, backCode, dflag, TxtColor, Rotation, exterior, Xpos, Ypos
	variable BarWidth, frame
	variable absX, absY, fracx, fracy

	// Look up the size of the graph window, in points
	GetWindow $graph, gsize
	variable g_left = V_left
	variable g_right = V_right
	variable g_top = V_top
	variable g_bottom = V_bottom

	// Look up the plot size in points
	GetWindow $graph, psize
	variable p_left = V_left
	variable p_right = V_right
	variable p_top = V_top
	variable p_bottom = V_bottom
	variable rgbR, rgbG, rgbB, rgbA

	// Annotation is not a color scale
	if(!StringMatch(type, "ColorScale"))
		return ""
	endif

	string Ywave = StringByKey("YWAVE", info, ":", ";", 1)
	if(!StringMatch(Ywave, trace)) // Actually, this isn't the color scale we wanted...skip it
		return ""
	endif
	obj += "\"colorbar\": {\r"
	anchorcode = StringByKey("A", flags, "=", "/", 1)
	backCode = StringByKey("B", flags, "=", "/", 1)
	dflag = StringByKey("D", flags, "=", "/", 1)
	exterior = StringByKey("E", flags, "=", "/", 1)
	frame = str2num(StringByKey("F", flags, "=", "/", 1))
	txtColor = "txtcolor(x)="+StringByKey("G", flags, "=", "/", 1) // prepend a string used to search in the standard way

	xPos = StringByKey("X", flags, "=", "/", 1)
	yPos = StringByKey("Y", flags, "=", "/", 1)
	absx = str2num(StringByKey("ABSX", info, ":", ";", 1))
	absy = str2num(StringByKey("ABSY", info, ":", ";", 1))
	fracx = (absx-p_left)/(p_right-p_left)
	fracy = (absy-p_bottom)/(p_top-p_bottom)
	obj += "\"x\":" + dub2str(fracx) + ",\r"
	obj += "\"y\":" + dub2str(fracy) + ",\r"
	obj += AnchorText(anchorcode)

	string csinfo = StringByKey("COLORSCALE", info, ":", ";", 1)
	variable width = str2num(StringByKey("width", csinfo, "=", ",", 1))
	variable widthpct = str2num(StringByKey("widthPct", csinfo, "=", ",", 1)) / 100
	variable length = str2num(StringByKey("height", csinfo, "=", ",", 1))
	variable lengthpct = str2num(StringByKey("heightPct", csinfo, "=", ",", 1)) / 100
	if((width == 0) && (widthpct == 0)) // Default width
		obj += "\"thickness\":" + dub2str(round(15 * ScreenResolution / 72)) + ",\r"
		obj += "\"thicknessmode\":\"pixels\",\r"
	elseif(width > 0)
		obj += "\"thickness\":" + dub2str(round(width * ScreenResolution / 72)) + ",\r"
		obj += "\"thicknessmode\":\"pixels\",\r"
	else
		obj += "\"thickness\":" + dub2str(widthpct) + ",\r"
		obj += "\"thicknessmode\":\"fraction\",\r"
	endif

	if((length == 0) && (lengthpct == 0) )
		obj += "\"len\":" + dub2str(0.75) + ",\r" // Igor's default CS height
		obj += "\"lenmode\":\"fraction\",\r"
	elseif(length > 0)
		obj += "\"len\":" + dub2str(round(length * ScreenResolution / 72)) + ",\r"
		obj += "\"lenmode\":\"pixels\",\r"
	else
		obj += "\"len\":" + dub2str(lengthpct) + ",\r"
		obj += "\"lenmode\":\"fraction\",\r"
	endif

	if(frame == 2) // Draw a border
		if(strsearch(dflag, "{", 0) > -1) // fancy flag: take just thefirst number, the actual borderwidth
			dflag = "dflag(x)=" + dflag
			dflag = dub2str(GetNumFromModifyStr(dflag, "dflag", "{", 0))
		endif
	elseif(frame == 0) // Don't draw a border
		dflag="0"
	endif

	obj += "\"borderwidth\":" + dflag + ",\r"
	string framesize = StringByKey("frame", info, "=", ",")
	obj += "\"outlinewidth\":" + framesize + ",\r"
	if(StringMatch(backCode[0], "(")) // The background code is a color
		backCode = "bgcolor(x)=" + backCode // Add a key for the standard format for the key searcher
		rgbR = round(GetNumFromModifyStr(backCode, "bgcolor", "(", 0) / 257)
		rgbG = round(GetNumFromModifyStr(backCode, "bgcolor", "(", 1) / 257)
		rgbB = round(GetNumFromModifyStr(backCode, "bgcolor", "(", 2) / 257)
		rgbA = 1
	elseif(str2num(backCode) == 1 ) // transparent background
		rgbR = 0
		rgbG = 0
		rgbB = 0
		rgbA = 0
	endif
	obj += "\"bgcolor\":\"rgba(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + "," + dub2str(rgbA) + ")\",\r"

	string defaultFnt = GetDefaultFont(graph)
	variable defaultTextSizePT = GetDefaultFontSize(graph, "") // This number is returned in POINTS

	// Axis Label/Title

	rgbR = round(GetNumFromModifyStr(txtcolor, "txtcolor", "(", 0) / 257)
	rgbG = round(GetNumFromModifyStr(txtcolor, "txtcolor", "(", 1) / 257)
	rgbB = round(GetNumFromModifyStr(txtcolor, "txtcolor", "(", 2) / 257)
	obj += "\"tickcolor\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"

	string LblTxt = StringByKey("TEXT", info, ":", ";", 1)
	string altFont // Try to read a font escape code, and extract it if it exists
	variable altFontSize, OZ // Try to read a font size escpe code, and extract if it exists
	LblTxt = ProcessText(LblTxt, altFont, altFontsize, OZ)
	obj += "\"tickfont\":{\r"
	obj += "\"color\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"

	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r"
	string nticks = StringByKey("nticks", csinfo, "=", ",", 1)
	variable ticklen = str2num(StringByKey("tickLen", csinfo, "=", ",", 1))
	string tickthick = StringByKey("tickThick", csinfo, "=", ",", 1)
	obj += "\"nticks\":" + nticks + ",\r"

	if(tickLen == -1) // Auto = 0.7 Text size
		tickLen = 0.7 * txt2px(defaultTextSizePT)
		obj += "\"ticks\":\"outside\",\r"
	elseif(tickLen > -1) // Normal outside ticks
		obj += "\"ticks\":\"outside\",\r"
	elseif(tickLen < -50) // Inside ticks
		obj += "\"ticks\":\"inside\",\r"
		ticklen = -(ticklen + 50)
	else // should have been crossing, Make them outside, I guess
		obj += "\"ticks\":\"outside\",\r"
		ticklen = -ticklen
	endif
	obj += "\"ticklen\":" + dub2str(tickLen) + ",\r"
	obj += "\"tickwidth\":" + tickThick + ",\r"
	obj += "\"title\":\"" + LblTxt + "\",\r"
	obj += "\"titleside\":\"right\",\r"
	obj += "\"titlefont\":{\r"
	if(!StringMatch(altFont, "default"))
		obj += "\"family\":\"" + altFont + "\",\r"
	endif
	if(AltFontSize > 0)
		obj += "\"size\":" + num2str(txt2px(AltFontSize)) + ",\r"
	endif

	// Do Text and colorbar frame color. They are the same unless a flag is set,
	// so keep this group together.
	obj += "\"color\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"
	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r"
	variable Fri = strsearch(csInfo, "frameRGB", 0)
	if(Fri > -1)
		variable FrEnd = strsearch(csInfo, ")", Fri + 1)
		string FrameRGB = "frameRGB(x)=" + csInfo[Fri + 9, FrEnd]
		rgbR = round(GetNumFromModifyStr(FrameRGB, "frameRGB", "(", 0) / 257)
		rgbG = round(GetNumFromModifyStr(FrameRGB, "rameRGB", "(", 1) / 257)
		rgbB = round(GetNumFromModifyStr(FrameRGB, "rameRGB", "(", 2) / 257)
	endif
	obj += "\"outlinecolor\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"
	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r"
	obj += "\"showscale\":true,\r"

	return obj
End

Function PlotlySetUser([user, key])
	string user, key

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Plotly
	if(!ParamIsDefault(user))
		string/G root:Packages:Plotly:userName = user
	endif
	if(!ParamIsDefault(key))
		string/G root:Packages:Plotly:userKey = key
	endif
End

Menu "Graph"
	"Graph2Plotly", Graph2Plotly()
End

/// @brief Main entry point
///
/// @param graph         [optional] default: Use the top graph
/// @param output        [optional] default: Use the name of the experiment.
/// @param skipSend      [optional] defaull: 1 (Do not send the graph to plot.ly)
/// @param KeepCMD       [optional] default: 0 (Do not keep the CMD output notebook)
/// @param writeFile     [optional] default: 1 (Write output to a json file in home)
Function Graph2Plotly([graph, output, keepCMD, writeFile])
	string graph, output
	variable KeepCMD
	variable writeFile

	if(ParamIsDefault(output) )
		output = IgorInfo(1) + ".json"
	endif
	if(ParamIsDefault(KeepCMD))
		KeepCMD = 0
	endif
	if(ParamIsDefault(graph))
		graph = WinName(0, 1)
	endif
	if(ParamIsDefault(writeFile))
		writeFile = 1
	endif

	DoWindow $graph
	if(V_flag==0)
		print "No Such Graph"
		return -1
	endif

	// We're going to store information about the graph in the Plotly Package data folder.
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Plotly                  // Make sure this exists.
	string/G root:Packages:Plotly:HaxisList = ""          // Store some global axis variables
	string/G root:Packages:Plotly:VaxisList = ""
	variable/G root:Packages:Plotly:sizeMode = 0          // Use to Store the size range of the igor graph for autosizing various features.
	variable/G root:Packages:Plotly:DefautTextSize
	variable/G root:Packages:Plotly:defaultTickLength
	variable/G root:Packages:Plotly:defaultMarkerSize     // In Igor size, not points
	variable/G root:Packages:Plotly:MarkerFlag = 0        // Set this flag to adjust "axis standoff"...it tells us whether we have marerks or not
	variable/G root:Packages:Plotly:LargestMarkerSize = 0 // Set is the largest actual marker size we use, which we need to know for axis standoff, or padding Units are px
	variable/G root:Packages:Plotly:Standoff = 0
	variable/G root:Packages:Plotly:HL=0 // are the four standoff correction variables
	variable/G root:Packages:Plotly:HR=0
	variable/G root:packages:Plotly:VT=0
	variable/G root:packages:Plotly:VB=0
	string/G root:packages:Plotly:BarToMode="NULL"
	variable/G root:packages:Plotly:TraceOrderFlag=0
	variable/G root:packages:Plotly:catGap=-1
	variable/G root:packages:Plotly:barGap=-1
	SVAR HaxisList = root:Packages:Plotly:HaxisList
	SVAR VaxisList = root:Packages:Plotly:VaxisList
	NVAR sizeMode = root:Packages:Plotly:sizeMode
	NVAR defaultTextSize = root:Packages:Plotly:DefautTextSize
	NVAR defaultTickLength = root:Packages:Plotly:defaultTickLength
	NVAR defaultMarkerSize = root:Packages:Plotly:defaultMarkerSize // In Igor size, not points	
	NVAR MarkerFlag = root:Packages:Plotly:MarkerFlag
	NVAR LargestMarkerSize = root:Packages:Plotly:LargestMarkerSize
	NVAR Standoff = root:Packages:Plotly:Standoff // If any axis has an axis standoff, then set this variable to 1, and use Plotly padding to avoid covering the marker
	NVAR HL = root:Packages:Plotly:HL
	NVAR HR = root:Packages:Plotly:HR
	NVAR VT = root:Packages:Plotly:VT
	NVAR VB = root:Packages:Plotly:VB
	NVAR catGap = root:Packages:Plotly:catGap
	NVAR barGap = root:Packages:Plotly:barGap
	SVAR barToMode = root:packages:Plotly:BarToMode
	NVAR TraceOrderFlag = root:packages:Plotly:TraceOrderFlag

	string list

	GetWindow $graph, gsizeDC // Look up the size of the graph window, in pixels
	variable Wheight = V_bottom - V_top
	variable Wwidth = V_right - V_left
	variable sizeLimiter = min(wHeight, Wwidth)
	variable win_bot = V_bottom
	variable win_top = V_top
	variable win_left = V_left
	variable win_right = V_right
	string info

	// Set the Igor graph size flag:
	//
	//   | Graph Size | Text Size | Tick Length | Marker Size
	// --+------------+-----------+-------------+------------
	// 1 | 267px      | 9pt       | 8pt         | 5 pt (inside dimension, so Igor size would be 2, because 2*2+1 = 5)
	// 2 | 467px      | 10pt      | 9pt         | 7 pt
	// 3 | 667px      | 12pt      | 11pt        | 9pt
	// 4 | 801px      | 14pt      | 13pt        | 13pt
	// 5 | 800px      | 18pt      | 16pt        | 15pt

	if(sizeLimiter < 267)
		sizeMode = 1
		defaultTextSize = 9
		defaultTickLength = 8
		defaultMarkerSize = 2
	elseif(sizeLimiter < 467)
		sizeMode = 2
		defaultTextSize = 10
		defaultTickLength = 9
		defaultMarkerSize = 3
	elseif(sizeLimiter < 667)
		sizeMode = 3
		defaultTextSize = 12
		defaultTickLength = 11
		defaultMarkerSize = 4
	elseif(sizeLimiter < 801)
		sizeMode = 4
		defaultTextSize = 14
		defaultTickLength = 13
		defaultMarkerSize = 13
	else
		sizeMode = 5
		defaultTextSize = 18
		defaultTickLength = 16
		defaultMarkerSize = 15
	endif

	string plyName = graph + "_CMD"

	// Create the notebook and add header info
	DoWindow $plyName
	if(V_flag)
		DoWindow/K $plyName
	endif
	NewNoteBook/N=$plyName/F=0
	oPlystring(plyName, "{")

	// DATA
	oPlystring(plyName, "\"data\": [\r")
	variable index = 0
	string traceName
	string obj = ""

	// IMAGES
	list = ImageNameList(graph, ";")
	do
		traceName = StringFromList(index, list)
		if(strlen(traceName) == 0)
			break // no more traces
		endif
		Obj += CreateImageObj(traceName, graph) + ",\r"
		index += 1
	while(1)

	// CONTOURS
	list = ContourNameList(graph, ";")
	index=0
	do
		traceName = StringFromList(index, list)
		if(strlen(traceName) == 0)
			break // no more traces, so move on to next section
		endif
		// Now Make a trace object
		obj += CreateContourObj(traceName, graph) + ",\r"
		index += 1
	while(1)

	// TRACES
	// ======

	// There are a couple of cases when we need to change the order of the
	// traces for Plotly: stacked bar charts, and fill to next scatter plots.

	// We'll store all the traces in a wave, then sort them if needed, then
	// write them to the plotly output

	Make/FREE/O/T/N=0 TraceObjectWave
	list = TraceNameList(graph, ";", 1 )
	index=0
	do // Step through all traces on Graph
		traceName = StringFromList(index, list)
		if(strlen(traceName) == 0)
			break // no more traces, so move on to next section
		endif
		// Now make a trace object
		InsertPoints index, 1, TraceObjectWave
		TraceObjectWave[index] = CreateTrObj(traceName, graph)
		index += 1
	while(1)

	// Make sure there are more than 0 traces before we try to write any
	if(index > 0)
		oPlystring(plyName, obj) // First write the image part, INCLUDING the comma
		variable numTraces = index
		if(TraceOrderFlag) // Reverse the order
			Duplicate/O/Free/T TraceObjectWave TempTOW
			TraceObjectWave = TempTOW[numTraces-p-1]
		endif

		index = 0
		do // Output the data to the notebook
			oPlystring(plyName, TraceObjectWave[index])
			if(index < numTraces - 1)
				oPlystring(plyName, ",\r") // Need a comma between traces, but not after the last trace
			endif
			index += 1
		while (index < numTraces)
	else // No traces, write the images but first get rid of the comma
		obj = obj[0, strlen(obj) - 3]
		oPlystring(plyName, obj)
	endif

	oPlystring(plyName, "\r],\r")

	// LAYOUT
	obj = "\"layout\" : {\r"

	// Set up the graph margins
	GetWindow $graph, psizeDC
	variable pheight = V_bottom - V_top
	variable pwidth = V_right - V_left
	variable p_bottom = V_bottom
	variable p_top = V_top
	variable p_left = V_left
	variable p_right = V_right
	variable m_L = p_left - win_left
	variable m_R = win_right - p_right
	variable m_T = p_top - win_top
	variable m_B = win_bot - p_bottom

	// We need to plan ahead and figure out if we need any standoff axes before
	// we go and set the scales. We only need to check the four main axes
	if(FindListItem("left", Vaxislist) > -1)
		info = AxisInfo(graph, "left")
		if(GetNumFromModifyStr(info, "standoff", "", 0) == 1)
			HL = LargestMarkerSize * 2
			if(GetNumFromModifyStr(info, "mirror", "", 0) > 0)
				HR = LargestMarkerSize*2
			endif
		endif
	endif
	if(FindListItem("right", Vaxislist) > -1)
		info = AxisInfo(graph, "right")
		if(GetNumFromModifyStr(info, "standoff", "", 0) == 1) // Standoff enabled
			HR = LargestMarkerSize*2
			if(GetNumFromModifyStr(info, "mirror", "", 0) > 0) // Need to adjust mirror too
				HL = LargestMarkerSize*2
			endif
		endif
	endif
	if(FindListItem("top", Haxislist) > -1)
		info = AxisInfo(graph, "top")
		if(GetNumFromModifyStr(info, "standoff", "", 0) == 1) // Standoff enabled
			VT = LargestMarkerSize*2
			if(GetNumFromModifyStr(info, "mirror", "", 0) > 0) // Need to adjust mirror too
				VB = largestMarkerSize*2
			endif
		endif
	endif
	if(FindListItem("bottom", Haxislist) > -1)
		info = AxisInfo(graph, "bottom")
		if(GetNumFromModifyStr(info, "standoff", "", 0) == 1) // Standoff enabled
			VB = LargestMarkerSize * 2
			if(GetNumFromModifyStr(info, "mirror", "", 0) > 0) // Need to adjust mirror too
				VT = largestMarkerSize * 2
			endif
		endif
	endif

	// Step through the AXES
	index = 0
	string PlyAxName
	// horizontal axes
	do
		string axisname = StringFromList(index, Haxislist)
		if(strlen(axisName) == 0)
			break // no more axes
		endif
		if(index > 0)
			PlyAxName = "xaxis", dub2str(index + 1)
		else
			PlyAxName = "xaxis"
		endif
		obj += CreateAxisObj(AxisName, PlyAxName, graph, "H", index)
		index += 1
	while(1)

	// vertical axes
	index = 0
	do
		axisname = StringFromList(index, Vaxislist)
		if(strlen(axisName) == 0)
			break // no more axes
		endif
		if(index > 0)
			PlyAxName = "yaxis", dub2str(index + 1)
		else
			PlyAxName = "yaxis"
		endif
		Obj += CreateAxisObj(AxisName, PlyAxName, graph, "V", index)
		index += 1
	while(1)

	if(!StringMatch(BarToMode, "NULL"))
		obj += "\"barmode\":\"" + BarToMode + "\",\r"
	endif
	if(catGap > -1) // these variables are initialized to -1, so if they are bigger, they have been set and we need to send them. Otherwise, don't clutter.
		obj += "\"bargap\":" + dub2str(catGap) + ",\r"
	endif
	if(barGap > -1)
		obj += "\"bargroupgap\":" + dub2str(barGap) + ",\r"
	endif

	// Look for a Legend in the annotations
	list = AnnotationList(graph)
	index = 0
	string AnnotationName
	variable CreateLegend = 0
	do
		AnnotationName = StringFromList(index, List)
		if(strlen(AnnotationName) == 0)
			break // no more axes
		endif
		Obj += CreateLegendObj(AnnotationName, graph, CreateLegend)
		index += 1
	while(1)
	if(CreateLegend)
		obj += "\"showlegend\":true,\r"
	else
		obj += "\"showlegend\":false,\r"
	endif

	// Step through the annotations looking for note-types for Plotly. These
	// have their own section in plotly, so we have to step through agian
	index = 0
	string AnnObj = ""
	do
		AnnotationName = StringFromList(index, List)
		if(strlen(AnnotationName) == 0)
			break // no more axes, so move on to next section
		endif
		AnnObj += CreateAnnotationObj(AnnotationName, graph)
		index += 1
	while(1)

	AnnObj = AnnObj[0, strlen(annObj) - 3]
	if(!StringMatch(AnnObj, ""))
		obj += "\"annotations\":[\r"
		obj += AnnObj
		obj += "\r],\r"
	endif

	obj += "\"height\":" + dub2str(Wheight + 45) + ",\r"
	obj += "\"width\":" + dub2str(Wwidth + 20) + ",\r"
	obj += "\"autosize\":false,\r"

	obj += "\"margin\": {\r"
	obj += "\"l\" : " + dub2str(m_L + 10) + ",\r" // The +10 is a kludge because text position can't be set in Plotly
	obj += "\"r\" : " + dub2str(m_R + 10) + ",\r"
	obj += "\"t\" : " + dub2str(m_T + 10 + 25) + ",\r"	// Add extra 25 for the little Plotly buttons
	obj += "\"b\" : " + dub2str(m_B + 10) + ",\r"
	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r"

	// Done stepping through the AXES
	// Graph colors
	variable rgbR, rgbG, rgbB
	WMGetGraphPlotBkgColor(graph, rgbR, rgbG, rgbB)
	rgbR = round(rgbR/257)
	rgbG = round(rgbG/257)
	rgbB = round(rgbB/257)
	obj += "\"plot_bgcolor\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"
	WMGetGraphWindowBkgColor(graph, rgbR, rgbG, rgbB)
	rgbR = round(rgbR/257)
	rgbG = round(rgbG/257)
	rgbB = round(rgbB/257)
	obj += "\"paper_bgcolor\":\"rgb(" + dub2str(rgbR) + "," + dub2str(rgbG) + "," + dub2str(rgbB) + ")\",\r"
	obj += "\"separators\":\".\",\r"
	// Set Graph default font information
	string defaultFontFamily = GetDefaultFont(graph)
	variable defaultFontSize = GetDefaultFontSize(graph, "")
	obj += "\"font\":{\r"
	obj += "\"family\":\"" + defaultFontFamily + "\",\r"
	obj += "\"size\":" + dub2str(Txt2Px(defaultFontSize)) + ",\r"
	obj += "\"color\":\"rgb(0,0,0)\"\r"
	obj += "},\r"

	obj = obj[0, strlen(obj) - 3]
	obj += "\r},\r" // End of Layout
	obj = obj[0, strlen(obj) - 3]
	oPlystring(plyName, obj)

	oPlystring(plyName, "}") // end of main object

	if(writeFile)
		Notebook $plyName getData=2
		WriteOutput(S_Value, output)
	endif

	if(!keepCMD)
		DoWindow/K $plyName
	endif

	return 1
End

static Function IgorNB(str, [IgrName])
	string str, IgrName
	if(ParamIsDefault(IgrName))
		IgrName = "IgrGraphNB"
	endif
	DoWindow $IgrName
	if(V_flag==0)
		NewNoteBook/N=$IgrName
	endif
	Notebook $IgrName, text=str
End

// Make a new notebook to get ready for Ploty-formated commands, and add the
// default commands
static Function NewPlyNB(plyName)
	string plyName

	DoWindow $plyName
	if(V_flag)
		DoWindow/K $plyName
	endif

	NewNoteBook/N=$plyName/F=0
	oDefaultPlyInfo(plyName)
End

static Function oPlystring(plyName, str)
	string plyName, str

	DoWindow $plyName
	if(!V_Flag)
		print "Please create this Ply Window first"
	endif
	Notebook $plyName text=str
End

static Function oDefaultPlyInfo(plyName)
	string plyName

	string un = "un=fillinuser&\r" // @todo fill with data
	string key = "key=fillinkey&\r"
	string platform = "platform=Igor&\r"

	Notebook $plyName text=(un + key + platform)
End

// Remove carriage returns from string
static Function/s Strip(str)
	string str

	/// @todo figure out how to "grep" or othwise remove spaces preceeding the CR
	return ReplaceString("\r", str, "")
End

static Function ExtractRGB(rgbR, rgbG, rgbB, key, graph)
	variable &rgbR, &rgbG, &rgbB
	string key
	string graph

	string info
	variable index
	string window_macro = WinRecreation(graph, 1)

	index = strsearch(window_macro, key, 0)
	if(index < -1) // @todo check this condition
		print"Note, did not find the key"
		return 0
	else
		print "return", index, strsearch(window_macro, "\r", index)
	endif
End

/// Writes string str to filename
Function WriteOutput(str, filename)
	string str, filename

	variable refNum

	Open/Z/P=home refNum as filename
	if(!V_flag)
		FBinWrite refNum, str
		Close refNum
	else
		PathInfo home
		printf "Error: Could not write to output file at %s\r", S_path + filename
	endif
End