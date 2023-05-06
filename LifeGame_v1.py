# conda activate python3.10

from doctest import testfile
from tkinter import *
from tkinter import ttk

x_pos=0 #mouse posiotn recording
y_pos=0
cell_list=[] #2-D list memory
cell_length=10 #length of singal cell
cell_length_max=40
cell_length_min=3
cell_gap=0.1*cell_length #gap in two cells
row_max=0
column_max=0
beginning=False

test_count=100

class cell:
    def __init__(self,x1,y1,x2,y2,color,Canvas):
        self.x1=x1
        self.y1=y1
        self.x2=x2
        self.y2=y2
        self.color=color
        self.Canvas=Canvas
        self.neighbor=0
        self.liveCell=None
        self.determine_state()
        self.print()

    def determine_state(self):
        if self.color == "white":
            self.liveCell=True
        else:
            self.liveCell=False
    
    def switch_color(self):
        if not self.liveCell: #not have live cell
            self.change_color("white")
        else:
            self.change_color("grey")

    def ShiftPosition(self,dx,dy):
        self.x1=self.x1+dx
        self.y1=self.y1+dy
        self.x2=self.x2+dx
        self.y2=self.y2+dy
        self.print()
    
    def ZoomPosition(self,dx,dy,rate):
        self.x1=self.x1*rate+dx
        self.y1=self.y1*rate+dy
        self.x2=self.x2*rate+dx
        self.y2=self.y2*rate+dy
        self.print()

    def change_color(self,color):
        #self.Canvas.delete(self)
        self.color=color
        self.determine_state()
        self.print()

    def print(self):
        self.Canvas.create_rectangle(int(self.x1), int(self.y1), int(self.x2), int(self.y2), fill = self.color, outline="")

#---------------------------------------------------------------------------------------------------

#create new 2-D list and paint it out
#input:
#   row_num: nuber of cells in row
#   column_num: number of cells in column
#   cell_length: length for signal cell
#   Can: target canvas object
#output:
#   None
def create_cell_matrix(row_num,column_num,cell_length,Can):
    global row_max
    global column_max
    global cell_list
    row_max=row_num #record max row number into global variable
    column_max=column_num

    Can.delete(ALL)

    new_cell_list=[[0 for _ in range(column_num)] for _ in range(row_num)] #2-D list init
    shift_length=cell_length+cell_gap
    pre_x=2 #start positoin on canvas
    pre_y=2

    for row in range(row_num):
        for column in range(column_num):
            new_cell_list[row][column]=cell(pre_x, pre_y, pre_x+cell_length, pre_y+cell_length, "grey", Can) #create cell object in 2-D list system
            pre_x+=shift_length #move to next position
        pre_x=2
        pre_y+=shift_length #move to next position

    cell_list=new_cell_list

#remove previous contents in enter box and intert new message
#input:
#   enter: object of enter box
#   msg: insterted message
#output:
#   None
def insert_enterbox(enter,msg):
    enter.delete(0,"end")
    enter.insert(0,str(msg))

#submit edited value of rows and columns and repaint the canvas
#input:
#   row: row value
#   column: column value
#   Can: canvas object
#output:
#   None
def submit_command(row,column,Can):
    create_cell_matrix(row,column,cell_length,Can)

#stop running and reset all variables into initialization sets
#input:
#   row: row value
#   column: column value
#   Can: canvas object
#output:
#   None
def reset_command(row,column,Can):
    global beginning

    insert_enterbox(entry_row,int(canvas_height/(cell_length+cell_gap))-1)
    insert_enterbox(entry_column,int(canvas_width/(cell_length+cell_gap))-1)
    create_cell_matrix(row,column,cell_length,Can)
    beginning=False

#command of start button, start the game
#input:
#   None
#output:
#   None
def start_command():
    global beginning
    global test_count

    beginning=True
    start_game(test_count)

#Mark stop sign
#input:
#   None
#output:
#   None
def stop_command():
    global beginning

    beginning=False

#record new mouse position
#input:
#   event: mouse event
#output:
#   None
def rightKey_press(event):
    global x_pos
    global y_pos

    x_pos=event.x
    y_pos=event.y
    #print("right key pressing")

#moving canvas by draging right key
#input:
#   event: mouse event
#output:
#   None
def rightKey_moving(event):
    global x_pos
    global y_pos
    global cell_list

    Can.delete(ALL) #remove all components
    dx=event.x-x_pos
    dy=event.y-y_pos
    x_pos=event.x
    y_pos=event.y

    for row in cell_list:
        for cell in row:
            cell.ShiftPosition(dx,dy) #editing and painting cell

    #print("right key pressing and moving")

#Zoom in or out diagram, based on mouse position
#input:
#   event: mouse event
#output:
#   None
def wheel_rolling(event):
    global cell_list
    direction=event.delta
    rate=0.9

    #check length border
    if direction>0:
        if abs(cell_list[0][0].x1-cell_list[0][0].x2)<cell_length_max: #not reach minimum length
            Can.delete(ALL) #remove all components
            rate=2-rate #1.1 times
            dx=event.x*(1-rate) #mouse position shift, zoom figure out from where the mouse is pointed
            dy=event.y*(1-rate)

            for row in cell_list:
                for cell in row:
                    cell.ZoomPosition(dx,dy,rate) #editing and painting cell
            #print("Zoom out")
        else:
            print("maximum size")
    elif direction<0:
        if abs(cell_list[0][0].x1-cell_list[0][0].x2)>cell_length_min: #not reach maximum length
            Can.delete(ALL) #remove all components
            rate=rate #0.9 times
            dx=event.x*(1-rate)
            dy=event.y*(1-rate)

            for row in cell_list:
                for cell in row:
                    cell.ZoomPosition(dx,dy,rate) #editing and painting cell
            #print("Zoom in")
        else:
            print("minimum size")

#find out cell coordinate based on cell length and mouse position
#input:
#   event: mouse event
#output:
#   row: row value
#   column: column value
def find_cell(event):
    global cell_list

    cell_shift=cell_list[0][1].x1-cell_list[0][0].x1 #varying cell length
    column=int((event.x-cell_list[0][0].x1)/cell_shift) #row value
    row=int((event.y-cell_list[0][0].y1)/cell_shift)
    
    return row,column

#switch cell color
#input:
#   event: mouse event
#output:
#   None
def left_press(event):
    global cell_list

    [row,column]=find_cell(event) #get target cell coordinate

    cell_list[row][column].switch_color()

    #print("left key pressing")

#switch cell color into white
#input:
#   event: mouse event
#output:
#   None
def leftKey_moving(event):
    global cell_list

    [row,column]=find_cell(event) #get target cell coordinate

    cell_list[row][column].change_color("white")

    #print("left key pressing and moving")

#refresh the canvas to increase tps(remaining trash reduce the running efficiency)
#input:
#   Can: target canvas object
#output:
#   None
def refresh_screen(Can):
    global row_max
    global column_max

    Can.delete(ALL)

    for row in cell_list:
        for cell in row:
            cell.print() #refresh matrix

#---------------------------------------------------------------------------------------------------
#mark cell's neighbor numbers
#input:
#   cell: cell object
#   row: cell's row value
#   column: cell's column value
#output:
#   None
def find_neighbor(cell,row,column):
    if cell.liveCell: #live cell
        global cell_list
        global row_max
        global column_max

        for i in range(-1,2):
            if row+i<0 or row+i>row_max-1: #out of range
                continue
            else:
                for j in range(-1,2):
                    if column+j<0 or column+j>column_max-1: #out of range
                        continue
                    else:
                       cell_list[row+i][column+j].neighbor+=1
        
        cell.neighbor-=1 #multi added

    else: #no cell
        pass

#check cell state. 3 neighbors born, 2 and 3 neighbors survival
#input:
#   cell: cell object
#output:
#   None
def check_state(cell):
    neighbors=cell.neighbor #get neighbor number

    if cell.liveCell:
        if neighbors !=2 and neighbors !=3: #dead
            cell.switch_color()
    else:
        if neighbors == 3: #born
            cell.switch_color()

    cell.neighbor=0 #init

#command of start button, start the game in each 1s
#input:
#   None
#output:
#   None
def start_game(count):
    global beginning

    if beginning: #start sign
        global cell_list
        global row_max
        global column_max

        for row in range(row_max):
            for column in range(column_max):
                find_neighbor(cell_list[row][column],row,column)

        for row in range(row_max):
            for column in range(column_max):
                check_state(cell_list[row][column])

        if not count%30:
            refresh_screen(Can)
        
        if count==0:
            root.destroy()

        #run start_button again after 100ms
        #root.after(100,start_game,count-1) #caution: start_button has no returns hence no () in needed here (or recursion error happens)
    else: #get stop sign
        pass

#---------------------------------------------------------------------------------------------------
#main window initialize
if __name__ == "__main__":
    root = Tk()
    root.title("TK")
    win_width=int(root.winfo_screenwidth()*1.0) #100% screen width
    win_length=int(root.winfo_screenheight()*1.0) #100% screen height
    root.geometry(str(win_width)+"x"+str(win_length)+"+"+str(int((root.winfo_screenwidth()-win_width)/2))+"+"+str(int((root.winfo_screenheight()-win_length)/2))) #set root size and place it into center
    frm = ttk.Frame(root)
    frm.grid() #layout components based on grid

    canvas_height=win_length*0.8 #80% root height
    canvas_width=win_width*1.0 #100% root width
    Can=Canvas(frm,height=canvas_height,width=canvas_width)

    lb_row=ttk.Label(frm, text="ROW: ") #label box: "ROW: "
    lb_row.grid(row=0,column=0)

    entry_row=ttk.Entry(frm) #enter box
    insert_enterbox(entry_row,int(canvas_height/(cell_length+cell_gap))-1)
    entry_row.grid(row=0,column=1)

    lb_column=ttk.Label(frm, text="COLUMN: ") #label box: "COLUMN: "
    lb_column.grid(row=0,column=2)

    entry_column=ttk.Entry(frm) #enter box
    insert_enterbox(entry_column,int(canvas_width/(cell_length+cell_gap))-1)
    entry_column.grid(row=0,column=3)

    #submit buttom, submit edited value from enter box
    button_sub=ttk.Button(frm, text="Submit", command=lambda:submit_command(int(entry_row.get()),int(entry_column.get()),Can))
    button_sub.grid(row=0,column=4)

    #resit buttom, initialize variables
    button_res=ttk.Button(frm, text="Reset", command=lambda:reset_command(int(canvas_height/(cell_length+cell_gap))-1,int(canvas_width/(cell_length+cell_gap))-1,Can))
    button_res.grid(row=0,column=5)

    #start buttom, start the game
    button_start=ttk.Button(frm, text="Start", command=start_command)
    button_start.grid(row=0,column=6)

    #stop buttom, stop the game
    button_stop=ttk.Button(frm, text="Stop", command=stop_command)
    button_stop.grid(row=0,column=7)

    Can.grid(row=1,column=0,columnspan=8) #park canvas, span 7 columns together
    create_cell_matrix(int(entry_row.get()),int(entry_column.get()),cell_length,Can)

    #quit button
    quit_button=ttk.Button(frm, text="Quit", command=root.destroy)
    quit_button.grid(row=2,column=0)

    Can.bind("<B3-Motion>",rightKey_moving)
    Can.bind("<ButtonPress-3>",rightKey_press)
    Can.bind("<MouseWheel>",wheel_rolling)
    Can.bind("<ButtonPress-1>",left_press)
    Can.bind("<B1-Motion>",leftKey_moving)

    #display window
    root.mainloop()