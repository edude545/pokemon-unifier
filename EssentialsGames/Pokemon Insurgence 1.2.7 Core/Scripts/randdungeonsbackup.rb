# This class is designed to favor different values more than a uniform
# random generator does
class AntiRandom
  def initialize(size)
    @old=[]
    @new=[]
    for i in 0...size
      @new[i]=i
    end
  end

  def get
    if @new.length==0
      # No new values
      @new=@old.clone
      @old.clear
    end
    if @old.length>0 && rand(7)==0
      # Get old value
      value=rand(@old.length)
      return @old[value]
    else
      if @new.length>0
        # Get new value
        value=rand(@new.length)
        ret=@new.delete_at(value)
        @old.push(ret)
        return ret
      else
        # Get old value
        value=rand(@old.length)
        return @old[value]
      end
    end
    return 0
  end
end



class DungeonMaze
  TILEWIDTH=13
  TILEHEIGHT=13

  def self.paintRect(tile,x,y,w,h) # paints a room
    for j in 0...h
      for i in 0...w
        tile[(j+y)*TILEWIDTH+(i+x)]=3
      end
    end
  end

  def self.paintTile(dungeon,dstX,dstY,tile,rotation) # paints a tile
    if rotation==None
      for y in 0...TILEHEIGHT;for x in 0...TILEWIDTH
        dungeon[x+dstX,y+dstY]=tile[y*TILEWIDTH+x]
      end;end
    elsif rotation==TurnLeft
      for y in 0...TILEHEIGHT;for x in 0...TILEWIDTH
        dungeon[y+dstX,TILEWIDTH-1-x+dstY]=tile[y*TILEWIDTH+x]
      end;end
    elsif rotation==TurnRight
      for y in 0...TILEHEIGHT;for x in 0...TILEWIDTH
        dungeon[TILEHEIGHT-1-y+dstX,x+dstY]=tile[y*TILEWIDTH+x]
      end;end
    elsif rotation==Turn180
      for y in 0...TILEHEIGHT;for x in 0...TILEWIDTH
        dungeon[TILEWIDTH-1-x+dstX,TILEHEIGHT-1-y+dstY]=tile[y*TILEWIDTH+x]
      end;end
    end
  end

  MINWIDTH=5
  MINHEIGHT=4
  MAXWIDTH=11
  MAXHEIGHT=10
  None=0
  TurnLeft=1
  TurnRight=2
  Turn180=3

  def self.paintCell(dungeon,xDst,yDst,tile,rotation)
    return false if !tile
    paintTile(dungeon,xDst,yDst,tile,rotation)
    if rand(10)<7
      # Generate a randomly placed room
      width=MINWIDTH+rand(MAXWIDTH-MINWIDTH+1)
      height=MINHEIGHT+rand(MAXHEIGHT-MINHEIGHT+1)
      return false if width<=0 || height<=0
      centerX=TILEWIDTH/2
      centerY=TILEHEIGHT/2
      centerX=(rand(2)==0) ? centerX-rand(3) : centerX+rand(3)
      centerY=(rand(2)==0) ? centerY-rand(3) : centerY+rand(3)
      x=centerX-(width/2)
      y=centerY-(height/2)
      rect=[x,y,width,height]
      rect[0]=1 if rect[0]<1
      rect[1]=2 if rect[1]<2
      rect[0]=TILEWIDTH-1-width if rect[0]+width>TILEWIDTH-1
      rect[1]=TILEHEIGHT-1-height if rect[0]+height>TILEHEIGHT-1
      dungeon.paint(rect,xDst,yDst)
      return true
    end
    return false
  end

  def self.generateTiles
    tiles=[]
    for i in 0...6
      tiles[i]=[]
      for j in 0...TILEWIDTH*TILEHEIGHT
        tiles[i][j]=0
      end   
    end
    paintRect(tiles[0],5,0,3,10) # N
    paintRect(tiles[1],5,0,3,8)  # N E
    paintRect(tiles[1],5,5,8,3)
    paintRect(tiles[2],5,0,3,8)  # N W E
    paintRect(tiles[2],0,5,13,3)
    paintRect(tiles[3],5,0,3,13) # N S
    paintRect(tiles[4],5,0,3,13)
    paintRect(tiles[4],0,5,13,3)
    realtiles=[
       [tiles[4],None],          # N W E S
       [tiles[2],Turn180],       # W E S
       [tiles[2],TurnRight],     # N E S
       [tiles[1],TurnRight],     # E S
       [tiles[2],TurnLeft],      # N W S
       [tiles[1],Turn180],       # W S
       [tiles[3],None],          # N S
       [tiles[0],Turn180],       # S
       [tiles[2],None],          # N W E
       [tiles[3],TurnLeft],      # W E
       [tiles[1],None],          # N E
       [tiles[0],TurnRight],     # E
       [tiles[1],TurnLeft],      # N W
       [tiles[0],TurnLeft],      # W
       [tiles[0],None],          # N
       [nil,None] 
    ]
    return realtiles
  end
end



module EdgeMasks
  North=1;West=2;East=4;South=8;Visited=16
end



# Dungeon generation algorithm found at:
# http://members.gamedev.net/potentialwell/ProceduralDungeonGeneration-JTippets.pdf

class MazeNode
  def initialize
    @edges=0
  end

  def setEdge(e); @edges|=e; end
  def clearEdge(e); @edges&=~e; end
  def clear; @edges=0; end
  def set; @edges=15; end
  def getEdge(e); return (@edges&e)!=0; end
  def isBlocked?; return @edges!=0; end
end



class NodeListElement
  attr_accessor :x,:y

  def initialize(x,y)
    @x=x;@y=y
  end
end



class Maze
  attr_accessor :cellWidth,:cellHeight,:nodeWidth,:nodeHeight

  def initialize(cw,ch)
    @nodes=[]
    @cells=[]
    raise ArgumentError.new if cw==0 || ch==0
    @cellWidth=cw
    @cellHeight=ch
    @nodeWidth=cw+1
    @nodeHeight=ch+1
    for i in 0...@nodeWidth*@nodeHeight
      @nodes[i]=MazeNode.new
    end
    for i in 0...cw*ch
      @cells[i]=0
    end
    clearAllEdges()
    clearAllCells()
  end

  def buildNodeList
    list=[]
    for x in 0...nodeWidth
      for y in 0...nodeHeight
        list.push(NodeListElement.new(x,y))    
      end
    end
    list.shuffle!
    return list
  end

  def setEdgeNode(x,y,edge)
    return if x<0||x>=nodeWidth||y<0||y>=nodeHeight
    @nodes[y*nodeWidth+x].setEdge(edge)
    e=0;nx=0;ny=0
    if edge==EdgeMasks::North
      e=EdgeMasks::South;nx=x;ny=y-1
    elsif edge==EdgeMasks::South
      e=EdgeMasks::North;nx=x;ny=y+1
    elsif edge==EdgeMasks::East
      e=EdgeMasks::West;nx=x+1;ny=y
    elsif edge==EdgeMasks::West
      e=EdgeMasks::East;nx=x-1;ny=y
    else
      return
    end
    return if nx<0||ny<0||nx>=nodeWidth||ny>=nodeHeight
    @nodes[ny*nodeWidth+nx].setEdge(e)
  end

  def clearEdgeNode(x,y,edge)
    return if x<0||x>=nodeWidth||y<0||y>=nodeHeight
    @nodes[y*nodeWidth+x].clearEdge(edge)
    e=0;nx=0;ny=0
    if edge==EdgeMasks::North
      e=EdgeMasks::South;nx=x;ny=y-1
    elsif edge==EdgeMasks::South
      e=EdgeMasks::North;nx=x;ny=y+1
    elsif edge==EdgeMasks::East
      e=EdgeMasks::West;nx=x+1;ny=y
    elsif edge==EdgeMasks::West
      e=EdgeMasks::East;nx=x-1;ny=y
    else
      raise ArgumentError.new
    end
    return if nx<0||ny<0||nx>=nodeWidth||ny>=nodeHeight
    @nodes[ny*nodeWidth+nx].clearEdge(e)
  end

  def isBlockedNode?(x,y)
    return false if x<0||y<0||x>=nodeWidth||y>=nodeHeight
    return @nodes[y*nodeWidth+x].isBlocked?
  end

  def getEdgeNode(x,y,edge)
    return false if x<0||y<0||x>=nodeWidth||y>=nodeHeight
    return @nodes[y*nodeWidth+x].getEdge(edge)
  end

  def getEdgePattern(x,y)
    pattern=0
    pattern|=EdgeMasks::North if getEdgeNode(x,y,EdgeMasks::North)
    pattern|=EdgeMasks::South if getEdgeNode(x,y,EdgeMasks::South)
    pattern|=EdgeMasks::East if getEdgeNode(x,y,EdgeMasks::East)
    pattern|=EdgeMasks::West if getEdgeNode(x,y,EdgeMasks::West)
    return pattern
  end

  def setAllEdges
    for c in 0...nodeWidth*nodeHeight
      @nodes[c].set
    end
  end

  def clearAllEdges
    for c in 0...nodeWidth*nodeHeight
      @nodes[c].clear
    end
  end

  def clearAllCells
    for c in 0...cellWidth*cellHeight
      @cells[c]=0
    end
  end

  def setVisited(x,y)
    return if x<0||y<0||x>=cellWidth||x>=cellHeight
    @cells[y*cellWidth+x]|=EdgeMasks::Visited
  end

  def getVisited(x,y)
    return false if x<0||y<0||x>=cellWidth||x>=cellHeight
    return (@cells[y*cellWidth+x]&EdgeMasks::Visited)!=0
  end

  def clearVisited(x,y)
    return if x<0||y<0||x>=cellWidth||x>=cellHeight
    @cells[y*cellWidth+x]&=~EdgeMasks::Visited
  end

  @@dirs=[EdgeMasks::North,EdgeMasks::South,
     EdgeMasks::East,EdgeMasks::West]

  def randomDir
    return @@dirs[rand(4)]
  end

  def buildMazeWall(x,y,dir,len)
    wx=x;wy=y
    return if isBlockedNode?(x,y)
    for c in 0...len
      ox=wx;oy=wy
      wy-=1 if dir==EdgeMasks::North
      wx-=1 if dir==EdgeMasks::West
      wx+=1 if dir==EdgeMasks::East
      wy+=1 if dir==EdgeMasks::South
      if isBlockedNode?(wx,wy)
        setEdgeNode(ox,oy,dir); return
      else
        setEdgeNode(ox,oy,dir)
      end
    end
  end

  def generateWallGrowthMaze(minWall=nil,maxWall=nil)
    minWall=0 if !minWall
    maxWall=cellWidth if !maxWall
    nlist=buildNodeList()
    return if nlist.length==0
    for c in 0...nlist.length
      d=randomDir()
      len=rand(minWall+(maxWall-minWall)+1)
      x=nlist[c].x
      y=nlist[c].y
      buildMazeWall(x,y,d,len)
    end
  end

  def recurseDepthFirst(x,y,depth)
    setVisited(x,y)
    dirs=@@dirs.shuffle!
    success=0
    for c in 0...4
      d=dirs[c]
      cx=0;cy=0
      case d
        when EdgeMasks::North; cx=x; cy=y-1
        when EdgeMasks::South; cx=x; cy=y+1
        when EdgeMasks::East; cx=x+1; cy=y
        when EdgeMasks::West; cx=x-1; cy=y
      end
      if cx>=0 && cy>=0 && cx<cellWidth && cy<cellHeight
        if !getVisited(cx,cy)
          clearEdgeNode(x,y,d)
          recurseDepthFirst(cx,cy,depth+1)
        end
      end
    end
  end

  def generateDepthFirstMaze
    sx=rand(cellWidth)
    sy=rand(cellHeight)
    setAllEdges()
    recurseDepthFirst(sx,sy,0)
  end
end



class Dungeon
  attr_accessor :width,:height
  XBUFFER=7
  YBUFFER=5

  class DungeonTable
    def initialize(dungeon)
	    @dungeon=dungeon
    end
  
    def xsize; @dungeon.width; end
    def ysize; @dungeon.height; end
    
    def [](x,y)
      [1,2,3,2][@dungeon[x,y]]
    end
  end

  def initialize(width,height)
    @width=width
    @height=height
    @array=[]
  end

  def clear
    for i in 0...width*height
      @array[i]=0
    end
  end

  def write
    ret=""
    i=0
    for y in 0...@height
      for x in 0...@width
        ret+=[" ",".","~"][value(x,y)]
        i+=1
      end
      ret+="\r\n"
    end
    return ret
  end

  def [](x,y)
    @array[y*@width+x]
  end

  def []=(x,y,value)
    @array[y*@width+x]=value
  end

  def value(x,y)
    return 0 if x<0||y<0||x>=@width||y>=@height
    @array[y*@width+x]
  end

  def get(x,y)
    return false if x<0||y<0||x>=@width||y>=@height
    @array[y*@width+x]!=0
  end

  def isWall?(x,y)
    if value(x,y)==0
      v1=value(x,y+1)
      return true if (v1==1||v1==3)
      if v1==0
        v1=value(x,y+2)
        return true if (v1==1||v1==3)
      end
    end
    return false
  end

  def isRoom?(x,y)
    if value(x,y)==1
      return false if value(x-1,y-1)==3
      return false if value(x,y-1)==3
      return false if value(x+1,y-1)==3
      return false if value(x-1,y)==3
      return false if value(x+1,y)==3
      return false if value(x-1,y+1)==3
      return false if value(x,y+1)==3
      return false if value(x+1,y+1)==3
      return true
    end
    return false
  end

  def generate
    self.clear
    maxWidth=@width-(XBUFFER*2)
    maxHeight=@height-(YBUFFER*2)
    cellWidth=DungeonMaze::TILEWIDTH
    cellHeight=DungeonMaze::TILEHEIGHT
    return if maxWidth<0 || maxHeight<0
    if maxWidth<cellWidth || maxHeight<cellHeight
      for x in 0...maxWidth
        for y in 0...maxHeight
          self[x+XBUFFER,y+YBUFFER]=1
        end
      end
      return
    end
    maze=Maze.new(maxWidth/cellWidth,maxHeight/cellHeight)
    maze.generateDepthFirstMaze()
    tiles=DungeonMaze.generateTiles()
    roomcount=0
    for y in 0...maxHeight/cellHeight
      for x in 0...maxWidth/cellWidth
        tile=maze.getEdgePattern(x,y)
        if DungeonMaze.paintCell(self,XBUFFER+x*cellWidth,
           YBUFFER+y*cellHeight,tiles[tile][0],tiles[tile][1])
          roomcount+=1
        end
      end
    end
    if roomcount==0
      # Handle situation where no rooms were generated
      for x in 0...maxWidth
        for y in 0...maxHeight
          self[x+XBUFFER,y+YBUFFER]=1
        end
      end
    end
    # Generate walls
    for y in 0...@height
      for x in 0...@width
        if isWall?(x,y)
          self[x,y]=2
        end
      end
    end
  end

  def generateMapInPlace(map)
    tbl=DungeonTable.new(self)
    for i in 0...map.width
      for j in 0...map.height
        nb=TileDrawingHelper.tableNeighbors(tbl,i,j)
        tile=TileDrawingHelper::NeighborsToTiles[nb]
        map.data[i,j,0]=tile+48*(tbl[i,j])
        map.data[i,j,1]=0
        map.data[i,j,2]=0
      end
    end
  end

  def paint(rect,offsetX,offsetY)
    for y in (rect[1]+offsetY...rect[1]+offsetY+rect[3])
      for x in (rect[0]+offsetX...rect[0]+offsetX+rect[2])
        self[x,y]=1 # room tile
      end
    end
  end

  def intersects?(r1,r2)
  	return !((( r2[0] + r2[2]  <= r1[0] ) || 
	   	 ( r2[0] >= r1[0] + r1[2] ) ||
		   ( r2[1] + r2[3] <= r1[1] ) || 
		   ( r2[1] >= r1[1] + r1[3] ) ) &&
		   (( r1[0] <= r2[0] + r2[2] )||
		   ( r1[0] >= r2[0] + r2[2] ) ||
		   ( r1[1] + r1[3] <= r2[1] ) || 
	   	 ( r1[1] >= r2[1] + r2[3] ))
		);
  end
end



def pbRandomRoomTile(dungeon,tiles)
  ar1=AntiRandom.new(dungeon.width)
  ar2=AntiRandom.new(dungeon.height)
  for i in 0...(tiles.length+1)*1000
    x=ar1.get()
    y=ar2.get()
    if dungeon.isRoom?(x,y) && (!tiles.any?{|item| 
       (item[0]-x).abs<2 && (item[1]-y).abs<2  })
      ret=[x,y]
      tiles.push(ret)
      return ret
    end
  end
  return nil
end

Events.onMapCreate+=proc {|sender, e|
   mapID=e[0]
   map=e[1]
   tileset=e[2]
   if pbGetMetadata(mapID,MetadataDungeon)
     # this map is a randomly generated dungeon
     dungeon=Dungeon.new(map.width,map.height)
     dungeon.generate
     dungeon.generateMapInPlace(map)
     roomtiles=[]
     # Reposition events
     for event in map.events.values
       tile=pbRandomRoomTile(dungeon,roomtiles)
       if tile
         event.x=tile[0]
         event.y=tile[1]
       end
     end
     # Override transfer X and Y
     tile=pbRandomRoomTile(dungeon,roomtiles)
     if tile
       $game_temp.player_new_x=tile[0]
       $game_temp.player_new_y=tile[1]
     end
   end
}