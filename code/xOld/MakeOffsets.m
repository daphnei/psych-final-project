function theOffsets = MakeOffsets(nMovePerFrame,dotCorr,dotMove,hOrV,noOrthRand)
% theOffsets = MakeOffsets(nMovePerFrame,dotCorr,dotMove,hOrV,noOrthRand)
%
% Make a dot offset array.
%
% 4/11/94		dhb		Wrote it.
% 4/12/94		dhb		Integer nCorr and nRand.
% 4/14/94		dhb		hOrV option
% 4/16/94		dhb		Changed hOrV option to angle
%									Control of random component.

% Use angle to compute horizontal and vertical components.
% Take sign of correlation into account
if (dotCorr < 0)
	dotCorr = -dotCorr;
	dotMove = -dotMove;
end
hDotMove = dotMove*cos(2*pi*hOrV/360);
vDotMove = dotMove*sin(2*pi*hOrV/360);

% Compute number of correlated and uncorrelated dots
nCorr = floor(nMovePerFrame*dotCorr);
nRand = nMovePerFrame-nCorr;
theOffsets = zeros(nMovePerFrame,2);

% Set correlated dots.
if (nCorr > 0)
	theOffsets(1:nCorr,1) = hDotMove*ones(nCorr,1);
	theOffsets(1:nCorr,2) = vDotMove*ones(nCorr,1);
end

% Set random dots.  There are two modes.  If noOrthRand == 1, then
% set uncorrelated dots with random horizontal and vertical components.
% Otherwise, set random dots moving only in same direction as main
% motion.
if (nRand > 0)
	if (noOrthRand == 1)
		theOffsets(nCorr+1:nMovePerFrame,1) = dotMove*NormalDraw(nRand,0,1);
		theOffsets(nCorr+1:nMovePerFrame,2) = dotMove*NormalDraw(nRand,0,1);
	else
		randDraw = NormalDraw(nRand,0,1);
		theOffsets(nCorr+1:nMovePerFrame,1) = hDotMove*randDraw;
		theOffsets(nCorr+1:nMovePerFrame,2) = vDotMove*randDraw;
	end
end

