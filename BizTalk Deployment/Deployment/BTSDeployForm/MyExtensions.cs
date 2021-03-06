﻿using System;
using System.Runtime.InteropServices;

namespace bizilante.Deployment.BTSDeployForm.Extensions
{
    public static class UIExtensions
    {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr SendMessage(
        IntPtr hWnd,
        uint Msg,
        IntPtr wParam,
        IntPtr lParam);

        private const int WM_VSCROLL = 277;
        private const int SB_LINEUP = 0;
        private const int SB_LINEDOWN = 1;
        private const int SB_TOP = 6;
        private const int SB_BOTTOM = 7;

        public static void ScrollToBottom(this System.Windows.Forms.TextBoxBase tb)
        {
            SendMessage(tb.Handle, WM_VSCROLL, new IntPtr(SB_BOTTOM), new IntPtr(0));
        }

        public static void ScrollToTop(this System.Windows.Forms.TextBoxBase tb)
        {
            SendMessage(tb.Handle, WM_VSCROLL, new IntPtr(SB_TOP), new IntPtr(0));
        }

        public static void ScrollLineDown(this System.Windows.Forms.TextBoxBase tb)
        {
            SendMessage(tb.Handle, WM_VSCROLL, new IntPtr(SB_LINEDOWN), new IntPtr(0));
        }

        public static void ScrollLineUp(this System.Windows.Forms.TextBoxBase tb)
        {
            SendMessage(tb.Handle, WM_VSCROLL, new IntPtr(SB_LINEUP), new IntPtr(0));
        }

    }
}

