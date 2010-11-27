#logic by itself in module

import pdb
import wx
from wx import xrc

import thimbl






class MyApp(wx.App):

    def OnInit(self):
        #self.res = xrc.XmlResource('thimbl.xrc')
        self.res = xrc.XmlResource('thimbl.xrc')
        self.data = thimbl.load_cache()
        self.init_follow()
        self.init_frame()
        return True

    def init_follow(self):
        self.follow_dialog = self.res.LoadDialog(None, 'dlg_follow')
        self.lst_followees = xrc.XRCCTRL(self.follow_dialog, 'lst_followees')
        self.lst_followees.InsertColumn(0, 'Nick')
        self.lst_followees.InsertColumn(1, 'Address')
        for f in thimbl.myplan(self.data)['following']:
            row = [f['nick'], f['address']]
            self.lst_followees.Append(row)

        
    def init_frame(self):
        self.frame = self.res.LoadFrame(None, 'frm_main')
        #self.panel = xrc.XRCCTRL(self.frame, 'panel')
        #self.text1 = xrc.XRCCTRL(self.panel, 'text1')
        #self.text2 = xrc.XRCCTRL(self.panel, 'text2')
        self.textctl = xrc.XRCCTRL(self.frame, 'txt_output')
        self.label = xrc.XRCCTRL(self.frame, 'label_1')
        self.frame.Bind(wx.EVT_BUTTON, self.OnFollow, id=xrc.XRCID('btn_follow'))
        self.frame.Bind(wx.EVT_BUTTON, self.OnFetch, id=xrc.XRCID('btn_fetch'))
        self.frame.Bind(wx.EVT_BUTTON, self.OnDisplayMessages, id=xrc.XRCID('btn_messages'))
        self.frame.Bind(wx.EVT_CLOSE, self.OnClose)
        self.frame.Show()
        
    def OnClose(self, ev):
        thimbl.save_cache(self.data)
        self.follow_dialog.Destroy()
        self.frame.Destroy()
        
    def output(self, text):
        self.textctl.write(text)
        self.textctl.write('\n')

    def OnSubmit(self, ev):
        print "button 1 called"
        text = self.textctl.GetLabel()
        self.label.SetLabel(text)
        
    def OnFetch(self, ev):
        thimbl.fetch(self.data, self.output)
        
    def OnDisplayMessages(self, ev):
        #pdb.set_trace()
        self.output('Messages:')
        thimbl.prmess(self.data, self.output)
        self.output('Finished printing messages')
        self.textctl.Refresh()

    def OnFollow(self, ev):
        self.follow_dialog.ShowModal()
        pass
    


if __name__ == '__main__':
    app = MyApp(False)
    app.MainLoop()
