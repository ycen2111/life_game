# conda activate python3.10

import sys
from time import sleep, time
from tkinter import *
from tkinter import ttk
import threading

sys.setrecursionlimit(3000)

x_pos=0 #mouse posiotn recording
y_pos=0

liveCell_list=[] #life cell list
newBorn_list=[] #has 3 neighbors but no live cell right now (new live cell in next round)

cell_list=[] #2-D list memory
cell_length=10 #length of singal cell
cell_length_max=40
cell_length_min=3
cell_gap=0.1*cell_length #gap in two cells
row_max=0
column_max=0
beginning=False
ergodic_mode=False

test_count=100
count=0
times=0

memory_dict={}

class cell:
    def __init__(self,x1,y1,x2,y2,color,Canvas):
        self.x1=x1
        self.y1=y1
        self.x2=x2
        self.y2=y2
        self.Canvas=Canvas
        self.neighbor=0
        self.liveCell=False
        self.determine_state(color)
        #self.print()

    def determine_state(self,color):
        if color == "white":
            self.liveCell=True
        else:
            self.liveCell=False
    
    def switch_state(self,print=True):
        self.liveCell=not self.liveCell
        if print:
            self.print()

    def ShiftPosition(self,dx,dy):
        self.x1=self.x1+dx
        self.y1=self.y1+dy
        self.x2=self.x2+dx
        self.y2=self.y2+dy
        #self.print()
    
    def ZoomPosition(self,dx,dy,rate):
        self.x1=self.x1*rate+dx
        self.y1=self.y1*rate+dy
        self.x2=self.x2*rate+dx
        self.y2=self.y2*rate+dy
        #self.print()

    def change_color(self,color,print=True):
        #self.Canvas.delete(self)
        if color=="white":
            self.liveCell=True
        else:
            self.liveCell=False
        if print:
            self.print()

    def print(self):
        if self.liveCell:
            self.Canvas.create_rectangle(int(self.x1), int(self.y1), int(self.x2), int(self.y2), fill = "white", outline="")
        else:
            self.Canvas.create_rectangle(int(self.x1), int(self.y1), int(self.x2), int(self.y2), fill = "grey", outline="")

#---------------------------------------------------------------------------------------------------
saver_limite=20
times_list=[]
top_savers_dict={}

class saver:
    def __init__(self,start,runs,maximum_cell):
        self.record_start(start)
        self.runs=runs
        self.maximum_cell=maximum_cell
    
    def refresh(self,start,runs,maximum_cell):
        self.record_start(start)
        self.runs=runs
        self.maximum_cell=maximum_cell

    def record_start(self,start):
        self.start=[]
        self.start.extend(start)

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
    redraw_matrix()

#paint cell matrix based on grey background,white line and white live cell only
#input:
#   None
#output:
#   None
def redraw_matrix():
    global row_max
    global column_max
    global cell_list
    global liveCell_list

    #grey background
    Can.create_rectangle(cell_list[0][0].x1, cell_list[0][0].y1, cell_list[row_max-1][column_max-1].x2, cell_list[row_max-1][column_max-1].y2, fill = "grey", outline="")
    line_width=cell_list[0][1].x1-cell_list[0][0].x2
    cell_distance=cell_list[0][1].x1-cell_list[0][0].x1

    if line_width<1:
        pass

    else:
        #draw vertical lines
        line_height=cell_list[row_max-1][column_max-1].y2
        x1=cell_list[0][0].x1-line_width
        for i in range(column_max):
            Can.create_rectangle(x1, 0, x1+line_width, line_height, fill = "white", outline="")
            x1+=cell_distance

        #draw horizonal lines
        line_height=cell_list[row_max-1][column_max-1].x2
        y1=cell_list[0][0].y1-line_width
        for j in range(row_max):
            Can.create_rectangle(0, y1, line_height, y1+line_width, fill = "white", outline="")
            y1+=cell_distance

    #paint white cell
    for row,column in liveCell_list:
        cell_list[row][column].print()

#read live cell list from list, change cell states and print them out
#input:
#   list: list of live cell
#output:
#   None
def read_memory(list):
    global liveCell_list

    for row,column in liveCell_list:
        cell_list[row][column].switch_state()

    liveCell_list=list

    for row,column in liveCell_list:
        cell_list[row][column].switch_state()
    
    Can.delete(ALL)
    redraw_matrix()

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
    global liveCell_list
    global times
    global memory_dict

    times=0
    memory_dict.clear()
    liveCell_list.clear()
    create_cell_matrix(row,column,cell_length,Can)

    stop_init()

#stop running and reset all variables into initialization sets
#input:
#   row: row value
#   column: column value
#   Can: canvas object
#output:
#   None
def reset_command(row,column,Can):
    global liveCell_list
    global times
    global memory_dict

    times=0
    memory_dict.clear()

    liveCell_list.clear()

    insert_enterbox(entry_row,int(canvas_height/(cell_length+cell_gap))-1)
    insert_enterbox(entry_column,int(canvas_width/(cell_length+cell_gap))-1)
    create_cell_matrix(row,column,cell_length,Can)

    stop_init()

#command of start button, start the game and init liveCell_list
#input:
#   None
#output:
#   None
def start_command():
    global ergodic_mode

    global row_max
    global column_max

    global cell_list
    global liveCell_list

    #liveCell_list.clear() #clear pre contents

    #for row in range(row_max):
    #    for column in range(column_max):
    #        if cell_list[row][column].liveCell:
    #            liveCell_list.append([row,column]) #sign up live cell

    start_init()
    if ergodic_mode:
        start_ergodic()
    else:
        start_game()

#Mark stop sign
#input:
#   None
#output:
#   None
def stop_command():
    stop_init()

#determine whether enter ergodic mode
def check_command():
    global ergodic_mode

    if check_button_value.get()==1:
        lb_column_borber.config(state=NORMAL)
        lb_row_borber.config(state=NORMAL)
        lb_cell_number.config(state=NORMAL)
        Maximum_runs.config(state=NORMAL)
        lb_savers.config(state=NORMAL)
        lb_Steps.config(state=NORMAL)
        entry_cell_number.config(state=NORMAL)
        entry_column_borber.config(state=NORMAL)
        entry_row_borber.config(state=NORMAL)
        insert_enterbox(entry_row_borber,5)
        insert_enterbox(entry_column_borber,5)
        insert_enterbox(entry_cell_number,10)

        ergodic_mode=True
    else:
        lb_column_borber.config(state=DISABLED)
        lb_row_borber.config(state=DISABLED)
        entry_column_borber.config(state=DISABLED)
        entry_row_borber.config(state=DISABLED)
        lb_cell_number.config(state=DISABLED)
        entry_cell_number.config(state=DISABLED)
        Maximum_runs.config(state=DISABLED)
        lb_savers.config(state=DISABLED)
        lb_Steps.config(state=DISABLED)

        ergodic_mode=False

#read last step or last step in ergodic mode
#input:
#   None
#output:
#   None
def read_last_step():
    global times
    global saver_limite
    global memory_dict
    global ergodic_mode
    global top_savers_dict

    if ergodic_mode:
        current_saver_key=int(lb_savers.cget("text")[7:])
        print(str(current_saver_key))
        if current_saver_key==0:
            current_saver_key=saver_limite
        
        if current_saver_key-1 not in top_savers_dict:
            pass
        else:
            read_memory(top_savers_dict[current_saver_key-1].start)
            lb_savers.config(text="Saver: "+str(current_saver_key-1))
            lb_Steps.config(text="Steps: "+str(top_savers_dict[current_saver_key-1].runs))
    else:
        times-=1
        read_memory(memory_dict[times])

#read next step or next step in ergodic mode
#input:
#   None
#output:
#   None
def read_next_step():
    global times
    global saver_limite
    global memory_dict
    global ergodic_mode
    global top_savers_dict

    if ergodic_mode:
        current_saver_key=int(lb_savers.cget("text")[7:])
        print(str(current_saver_key))
        if current_saver_key==saver_limite-1:
            current_saver_key=0-1
        
        if current_saver_key+1 not in top_savers_dict:
            pass
        else:
            read_memory(top_savers_dict[current_saver_key+1].start)
            lb_savers.config(text="Saver: "+str(current_saver_key+1))
            lb_Steps.config(text="Steps: "+str(top_savers_dict[current_saver_key-1].runs))
    else:
        times+=1
        read_memory(memory_dict[times])

def start_init():
    global beginning

    beginning=True
    button_start_stop.config(text="Stop")
    button_start_stop.config(command=stop_command)
    button_right.config(state=DISABLED)
    button_left.config(state=DISABLED)

def stop_init():
    global beginning

    button_start_stop.config(text="Start")
    button_start_stop.config(command=start_command)
    button_right.config(state=NORMAL)
    button_left.config(state=NORMAL)
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

    redraw_matrix()
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

    redraw_matrix()

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
    global liveCell_list

    [row,column]=find_cell(event) #get target cell coordinate

    cell_list[row][column].switch_state()
    if cell_list[row][column].liveCell: #live cell
        liveCell_list.append([row,column])
    else:
        liveCell_list.remove([row,column])

    #print("left key pressing")

#switch cell color into white
#input:
#   event: mouse event
#output:
#   None
def leftKey_moving(event):
    global cell_list
    global liveCell_list

    [row,column]=find_cell(event) #get target cell coordinate

    cell_list[row][column].change_color("white")
    if [row,column] not in liveCell_list:
        liveCell_list.append([row,column])

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

    redraw_matrix() #refresh matrix

def record_memory(dict,times):
    dict[times]=liveCell_list

#---------------------------------------------------------------------------------------------------

def thread_it(function, *args, name):
    exec("{}=threading.Thread(target={}, args={}, name=name)".format(function,args,name))
    exec("{}.setDaemon(True)".format(name))
    exec("{}.start()".format(name))

#---------------------------------------------------------------------------------------------------

def start_ergodic():
    global row_max
    global column_max
    global top_savers_dict

    cell_list=[]

    row_shift=int((row_max-int(entry_row_borber.get()))/2)
    column_shift=int((column_max-int(entry_column_borber.get()))/2)
    cell_number=int(entry_cell_number.get())

    distribute_init_cell(cell_list,cell_number,row_shift,column_shift,int(entry_row_borber.get()),int(entry_column_borber.get()),0)

    stop_init()
    for key in top_savers_dict:
        print(str(top_savers_dict[key].start)+" steps= "+str(top_savers_dict[key].runs))

def distribute_init_cell(cell_list,cell_number,row_shift,column_shift,row,column,start_point):
    global memory_dict
    global beginning
    global times

    for i in range(start_point,row*column-cell_number+1):
        real_row=int(i/5)+row_shift
        real_column=(i%5)+column_shift

        cell_list.append([real_row,real_column])
        if cell_number!=1:
            distribute_init_cell(cell_list,cell_number-1,row_shift,column_shift,row,column,i+1)
            cell_list.remove([real_row,real_column])
        else:
            #print(cell_list)
            memory_dict.clear()
            memory_dict[0]=cell_list

            read_memory(cell_list)
            root.update()
            #print(memory_dict[0])

            beginning=True
            start_game()
            record_saver(cell_list,times)

            times=0
            cell_list.remove([real_row,real_column])

def record_saver(cell_list,times):
    global saver_limite
    global top_savers_dict
    global times_list

    #print(times_list)
    if len(times_list)<saver_limite:
        top_savers_dict[len(times_list)]=saver(cell_list,times,None)
        times_list.append(times)
    else:
        if top_savers_dict[0].start==[[27, 57], [27, 58], [27, 59]]:
            pass

        minimum=min(times_list)
        if times>minimum:
            times_list.remove(minimum)
            times_list.append(times)
            for key in top_savers_dict:
                if top_savers_dict[key].runs==minimum:
                    top_savers_dict[key].refresh(cell_list,times,None)
                    Maximum_runs.config(text="Max steps: "+str(max(times_list)))
                    #print(top_savers_dict[key].start)
                    #print(str(min(times_list)))
                    break

#---------------------------------------------------------------------------------------------------
#mark cell's neighbor numbers by liveCell_list, and build newBorn_list
#input:
#   None
#output:
#   None
def find_neighbor():
    global cell_list
    global newBorn_list
    global liveCell_list

    global row_max
    global column_max

    for [row,column] in liveCell_list:
        for i in range(-1,2):
            if row+i<0 or row+i>row_max-1: #out of range
                continue
            else:
                for j in range(-1,2):
                    if column+j<0 or column+j>column_max-1: #out of range
                        continue
                    else:
                        n_row=row+i
                        n_column=column+j
                        cell_list[n_row][n_column].neighbor+=1

                        if not cell_list[n_row][n_column].liveCell: #newBorn_list only reocrd coord where have no life
                            if cell_list[n_row][n_column].neighbor==3:
                                newBorn_list.append([n_row,n_column])
                            elif cell_list[n_row][n_column].neighbor==4:
                                newBorn_list.remove([n_row,n_column])
            
        cell_list[row][column].neighbor-=1 #multi added

#check live cell state, remove dead cell out of liveCell_list. 2 and 3 neighbors survival
#input:
#   None
#output:
#   None
def check_liveCell_state():
    global cell_list
    global liveCell_list
    global ergodic_mode
    new_liveCell_list=[]

    for [row,column] in liveCell_list:
        neighbors=cell_list[row][column].neighbor #get neighbor number

        if neighbors !=2 and neighbors !=3: #dead
            cell_list[row][column].switch_state(print=not ergodic_mode)
        else: #survive
            new_liveCell_list.append([row,column])

    liveCell_list=new_liveCell_list

#operate nre born cell in newBorn_list
#input:
#   None
#output:
#   None
def new_born_cell():
    global newBorn_list
    global ergodic_mode

    for [row,column] in newBorn_list:
        cell_list[row][column].switch_state(print=not ergodic_mode)

#combine liveCell_list and newBorn_list together, clear cell.neighbors and newBorn_list
#input:
#   None
#output:
#   None
def pre_nextLoop():
    global cell_list
    global liveCell_list
    global newBorn_list

    liveCell_list=liveCell_list+newBorn_list
    newBorn_list.clear()
    #print(str(len(liveCell_list)))

    for list in cell_list:
        for cell in list:
            cell.neighbor=0

#command of start button, start the game in each 0.1s
#input:
#   None
#output:
#   None
def start_game():
    global beginning
    global memory_dict
    global test_count
    global count
    global times
    global ergodic_mode

    if beginning: #start sign
        find_neighbor()
        check_liveCell_state()
        new_born_cell()
        pre_nextLoop()
            
        record_memory(memory_dict,times)

        #if count==0:
        #    root.destroy()

        if ergodic_mode:
            #print(memory_dict)
            if times<1:
                times+=1
            elif len(memory_dict[times])==0:
                beginning=False
            elif times%10 and memory_dict[times-(times%10)]==memory_dict[times]: #avoid memory_dict[10]==memory_dict[10]
                beginning=False
            else:
                times+=1

            start_game()
            #root.after(100,start_game)
        else:
            if count==test_count:
                refresh_screen(Can)
                count=0
            count+=1
            times+=1

            #run start_button again after 100ms
            root.after(100,start_game) #caution: start_button has no returns hence no () in needed here (or recursion error happens)

    else: #get stop sign
        #print("times= "+str(times))
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
    button_start_stop=ttk.Button(frm, text="Start", command=start_command)
    button_start_stop.grid(row=0,column=6)

    #last step buttom, move to last step
    button_left=ttk.Button(frm, text="👈", command=read_last_step)
    button_left.grid(row=0,column=7)

    #next step buttom, move to next step
    button_right=ttk.Button(frm, text="👉", command=read_next_step)
    button_right.grid(row=0,column=8)

    Maximum_runs=ttk.Label(frm, text="Max steps: 0", state=DISABLED) #label box: "Cell number: "
    Maximum_runs.grid(row=0,column=9)

    Can.grid(row=1,column=0,columnspan=12) #park canvas, span 7 columns together
    create_cell_matrix(int(entry_row.get()),int(entry_column.get()),cell_length,Can)

    #quit button
    quit_button=ttk.Button(frm, text="Quit", command=root.destroy)
    quit_button.grid(row=2,column=0)

    #check button
    check_button_value=IntVar()
    check_button = ttk.Checkbutton(frm,text = "Ergodic Mode", command=check_command, variable=check_button_value)
    check_button.grid(row=2,column=1)

    lb_row_borber=ttk.Label(frm, text="ROW border: ", state=DISABLED) #label box: "ROW: "
    lb_row_borber.grid(row=2,column=2)

    entry_row_borber=ttk.Entry(frm, state=DISABLED) #enter box
    entry_row_borber.grid(row=2,column=3)

    lb_column_borber=ttk.Label(frm, text="COLUMN border: ", state=DISABLED) #label box: "COLUMN: "
    lb_column_borber.grid(row=2,column=4)

    entry_column_borber=ttk.Entry(frm, state=DISABLED) #enter box
    entry_column_borber.grid(row=2,column=5)

    lb_cell_number=ttk.Label(frm, text="Cell Number: ", state=DISABLED) #label box: "Cell number: "
    lb_cell_number.grid(row=2,column=6)

    entry_cell_number=ttk.Entry(frm, state=DISABLED) #enter box
    entry_cell_number.grid(row=2,column=7)

    lb_savers=ttk.Label(frm, text="Saver: 0", state=DISABLED) #label box: "Savers: "
    lb_savers.grid(row=2,column=8)

    lb_Steps=ttk.Label(frm, text="Steps: 0", state=DISABLED) #label box: "Savers: "
    lb_Steps.grid(row=2,column=9)

    Can.bind("<B3-Motion>",rightKey_moving)
    Can.bind("<ButtonPress-3>",rightKey_press)
    Can.bind("<MouseWheel>",wheel_rolling)
    Can.bind("<ButtonPress-1>",left_press)
    Can.bind("<B1-Motion>",leftKey_moving)

    #display window
    root.mainloop()