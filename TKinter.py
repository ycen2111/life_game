from tkinter import *
from tkinter import ttk

"""
    Represents a rectangular cell on a canvas.

    Attributes:
        x1 (int): The x-coordinate of the top-left corner of the cell.
        y1 (int): The y-coordinate of the top-left corner of the cell.
        x2 (int): The x-coordinate of the bottom-right corner of the cell.
        y2 (int): The y-coordinate of the bottom-right corner of the cell.
        color (str): The color of the cell.
        Canvas (Tkinter.Canvas): The canvas on which the cell is drawn.
    """
class cell:
    def __init__(self,x1,y1,x2,y2,color,Canvas):
        self.x1=x1
        self.y1=y1
        self.x2=x2
        self.y2=y2
        self.color=color
        self.Canvas=Canvas
        self.print()

    """
        Shifts the position of the cell by a specified amount.

        Args:
            dx (int): The amount to shift the cell in the x direction.
            dy (int): The amount to shift the cell in the y direction.
        """
    def ShiftPosition(self,dx,dy):
        self.x1=self.x1+dx
        self.y1=self.y1+dy
        self.x2=self.x2+dx
        self.y2=self.y2+dy
        self.print()

    """
        Draws the cell on the canvas.
        """
    def print(self):
        self.Canvas.create_rectangle(self.x1, self.y1, self.x2, self.y2, fill = self.color)

x_pos=0
y_pos=0
"""
    Handles mouse events.

    Args:
        event (Tkinter.Event): The mouse event.

    Returns:
        tuple: If the left mouse button is pressed, returns the new x and y positions of the mouse (int, int). 
               If the left mouse button is pressed and moving, returns the change in x and y position (int, int).
"""
def mouse_event(event):
    global x_pos
    global y_pos

    s=event.state #get event state id
    lb.config(text=event)

    if s==0: #left button press
        x_pos=event.x
        y_pos=event.y
        print("left key pressing")
        return x_pos, y_pos
    elif s==256: #press left button and moving
        Can.delete(ALL)
        dx=x_pos-event.x
        dy=y_pos-event.y
        x_pos=event.x
        y_pos=event.y
        c1.ShiftPosition(dx,dy)
        c2.ShiftPosition(dx,dy)
        print("left key and moving")
        return dx, dy
    

root = Tk()
root.title("TK")
win_width=int(root.winfo_screenwidth()*0.75)
win_length=int(root.winfo_screenheight()*0.75)
root.geometry(str(win_width)+"x"+str(win_length)+"+"+str(int((root.winfo_screenwidth()-win_width)/2))+"+"+str(int((root.winfo_screenheight()-win_length)/2)))
frm = ttk.Frame(root, padding=10)
frm.grid()

lb=ttk.Label(frm, text="                       ")
lb.grid(row=0,column=0)
ttk.Button(frm, text="Quit1", command=root.destroy).grid(row=1,column=0)
Can=Canvas(frm,height=win_length*0.8,width=win_width*0.95)
Can.grid(row=2)
c1=cell(2, 2, 22, 22, "black", Can)
c2=cell(24, 2, 44, 22, "black", Can)
Can.bind("<B1-Motion>",mouse_event)
Can.bind("<ButtonPress-1>",mouse_event)
Can.bind("<MouseWheel>",mouse_event)

root.mainloop()