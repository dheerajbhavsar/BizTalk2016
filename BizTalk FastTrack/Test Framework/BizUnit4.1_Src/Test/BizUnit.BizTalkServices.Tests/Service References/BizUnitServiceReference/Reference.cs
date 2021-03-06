﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace BizUnit.BizTalkServices.Tests.BizUnitServiceReference {
    using System.Runtime.Serialization;
    using System;
    
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0")]
    [System.Runtime.Serialization.DataContractAttribute(Name="ReceivePortConductorStep", Namespace="http://bizunit.datacontracts/2016/09/")]
    [System.SerializableAttribute()]
    public partial class ReceivePortConductorStep : object, System.Runtime.Serialization.IExtensibleDataObject, System.ComponentModel.INotifyPropertyChanged {
        
        [System.NonSerializedAttribute()]
        private System.Runtime.Serialization.ExtensionDataObject extensionDataField;
        
        [System.Runtime.Serialization.OptionalFieldAttribute()]
        private ReceivePortConductorStepReceivePortAction ActionField;
        
        [System.Runtime.Serialization.OptionalFieldAttribute()]
        private int DelayForCompletionField;
        
        [System.Runtime.Serialization.OptionalFieldAttribute()]
        private string ReceiveLocationNameField;
        
        [System.Runtime.Serialization.OptionalFieldAttribute()]
        private string ReceivePortNameField;
        
        [System.Runtime.Serialization.OptionalFieldAttribute()]
        private string ServerField;
        
        [global::System.ComponentModel.BrowsableAttribute(false)]
        public System.Runtime.Serialization.ExtensionDataObject ExtensionData {
            get {
                return this.extensionDataField;
            }
            set {
                this.extensionDataField = value;
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute()]
        public ReceivePortConductorStepReceivePortAction Action {
            get {
                return this.ActionField;
            }
            set {
                if ((this.ActionField.Equals(value) != true)) {
                    this.ActionField = value;
                    this.RaisePropertyChanged("Action");
                }
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute()]
        public int DelayForCompletion {
            get {
                return this.DelayForCompletionField;
            }
            set {
                if ((this.DelayForCompletionField.Equals(value) != true)) {
                    this.DelayForCompletionField = value;
                    this.RaisePropertyChanged("DelayForCompletion");
                }
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute()]
        public string ReceiveLocationName {
            get {
                return this.ReceiveLocationNameField;
            }
            set {
                if ((object.ReferenceEquals(this.ReceiveLocationNameField, value) != true)) {
                    this.ReceiveLocationNameField = value;
                    this.RaisePropertyChanged("ReceiveLocationName");
                }
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute()]
        public string ReceivePortName {
            get {
                return this.ReceivePortNameField;
            }
            set {
                if ((object.ReferenceEquals(this.ReceivePortNameField, value) != true)) {
                    this.ReceivePortNameField = value;
                    this.RaisePropertyChanged("ReceivePortName");
                }
            }
        }
        
        [System.Runtime.Serialization.DataMemberAttribute()]
        public string Server {
            get {
                return this.ServerField;
            }
            set {
                if ((object.ReferenceEquals(this.ServerField, value) != true)) {
                    this.ServerField = value;
                    this.RaisePropertyChanged("Server");
                }
            }
        }
        
        public event System.ComponentModel.PropertyChangedEventHandler PropertyChanged;
        
        protected void RaisePropertyChanged(string propertyName) {
            System.ComponentModel.PropertyChangedEventHandler propertyChanged = this.PropertyChanged;
            if ((propertyChanged != null)) {
                propertyChanged(this, new System.ComponentModel.PropertyChangedEventArgs(propertyName));
            }
        }
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0")]
    [System.Runtime.Serialization.DataContractAttribute(Name="ReceivePortConductorStep.ReceivePortAction", Namespace="http://schemas.datacontract.org/2004/07/BizUnit.TestSteps.BizTalk.Port")]
    public enum ReceivePortConductorStepReceivePortAction : int {
        
        [System.Runtime.Serialization.EnumMemberAttribute()]
        Enable = 0,
        
        [System.Runtime.Serialization.EnumMemberAttribute()]
        Disable = 1,
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ServiceModel.ServiceContractAttribute(Namespace="http://bizunit.servicecontracts/2016/09/", ConfigurationName="BizUnitServiceReference.IBizUnitService")]
    public interface IBizUnitService {
        
        [System.ServiceModel.OperationContractAttribute(Action="http://bizunit.servicecontracts/2016/09/IBizUnitService/ReceivePortConductorStep", ReplyAction="http://bizunit.servicecontracts/2016/09/IBizUnitService/ReceivePortConductorStepR" +
            "esponse")]
        void ReceivePortConductorStep(ReceivePortConductorStep step);
        
        [System.ServiceModel.OperationContractAttribute(Action="http://bizunit.servicecontracts/2016/09/IBizUnitService/GetData", ReplyAction="http://bizunit.servicecontracts/2016/09/IBizUnitService/GetDataResponse")]
        string GetData(int value);
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public interface IBizUnitServiceChannel : IBizUnitService, System.ServiceModel.IClientChannel {
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public partial class BizUnitServiceClient : System.ServiceModel.ClientBase<IBizUnitService>, IBizUnitService {
        
        public BizUnitServiceClient() {
        }
        
        public BizUnitServiceClient(string endpointConfigurationName) : 
                base(endpointConfigurationName) {
        }
        
        public BizUnitServiceClient(string endpointConfigurationName, string remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public BizUnitServiceClient(string endpointConfigurationName, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public BizUnitServiceClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(binding, remoteAddress) {
        }
        
        public void ReceivePortConductorStep(ReceivePortConductorStep step) {
            base.Channel.ReceivePortConductorStep(step);
        }
        
        public string GetData(int value) {
            return base.Channel.GetData(value);
        }
    }
}
