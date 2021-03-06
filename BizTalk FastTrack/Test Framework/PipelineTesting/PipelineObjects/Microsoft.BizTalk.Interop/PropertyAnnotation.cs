namespace Microsoft.BizTalk.Interop
{
    using System;
    using System.Runtime.InteropServices;

    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode), ComVisible(false)]
    internal sealed class PropertyAnnotation
    {
        private Guid PropID = Guid.Empty;
        [MarshalAs(UnmanagedType.BStr)]
        public string Name;
        [MarshalAs(UnmanagedType.BStr)]
        public string Namespace;
        [MarshalAs(UnmanagedType.BStr)]
        public string XPath;
        [MarshalAs(UnmanagedType.BStr)]
        public string XSDType;
        public int nTrackable;
    }
}

