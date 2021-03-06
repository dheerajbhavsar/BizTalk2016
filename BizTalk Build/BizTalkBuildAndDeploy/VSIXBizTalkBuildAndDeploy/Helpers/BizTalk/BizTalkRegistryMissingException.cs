﻿using System;
using System.Globalization;
using System.Runtime.Serialization;

namespace VSIXBizTalkBuildAndDeploy.Helpers.BizTalk
{
    [Serializable]
    public class BizTalkRegistryMissingException : Exception
    {
        // Methods
        public BizTalkRegistryMissingException()
            : base()
        {
        }

        public BizTalkRegistryMissingException(string message)
            : base(message)
        {
        }

        protected BizTalkRegistryMissingException(SerializationInfo serializationInfo, StreamingContext streamingContext)
            : base(serializationInfo, streamingContext)
        {
        }

        public BizTalkRegistryMissingException(string message, params object[] args)
            : base(string.Format(CultureInfo.CurrentCulture, message, args), null)
        {
        }

        public BizTalkRegistryMissingException(string message, Exception ex)
            : base(message, ex)
        {
        }

        // Properties
        public new string Message
        {
            get
            {
                return base.Message;
            }
        }

        public new string Source
        {
            get
            {
                return base.Source;
            }
            set
            {
                base.Source = value;
            }
        }
    }


}
