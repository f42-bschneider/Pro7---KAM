<aura:application >

    <ltng:require styles="/resource/SLDS/assets/styles/salesforce-lightning-design-system.min.css">
    </ltng:require>

    <aura:attribute name="value" type="Integer" access="public" default=""/>
    <aura:attribute name="options" type="Object[]" access="public" default="[{'text' : '1', 'label' : 'Buhu'}, {'text' : '2', 'label' : 'Blaha'}]"/>

    <!--<aura:handler event="c:f42_Select2Evt" action="{!c.myAction}" /> -->

    <!--<c:f42_SelectListCmp options="{!v.options}" selectedId="{!v.value}" required="true"/>-->

    <!--<c:f42_Toast aura:id="toaster" />-->

    <button onclick="{!c.showOppmodal}" > Hallo </button>

    <div class="slds">
        <div aria-hidden="true" tabindex="-1" aria-labelledby="header43" role="dialog" class="slds-modal slds-fade-in-hide" aura:id="modaldialog">

            <div class="slds-modal__container">

                <div class="slds-modal__header">
                    <h2 id="header43" class="slds-text-heading--medium">Modal Header</h2>
                </div>

                <div class="slds-modal__content slds-p-around--medium">
                    <div>
                        <p>Sit nulla est ex deserunt exercitation anim occaecat. Nostrud ullamco deserunt aute id consequat veniam incididunt duis in sint irure nisi. Mollit officia cillum Lorem ullamco minim nostrud elit officia tempor esse quis. Cillum sunt ad dolore
                          quis aute consequat ipsum magna exercitation reprehenderit magna. Tempor cupidatat consequat elit dolor adipisicing.</p>
                        <p>Dolor eiusmod sunt ex incididunt cillum quis nostrud velit duis sit officia. Lorem aliqua enim laboris do dolor eiusmod officia. Mollit incididunt nisi consectetur esse laborum eiusmod pariatur proident. Eiusmod et adipisicing culpa deserunt
                          nostrud ad veniam nulla aute est. Labore esse esse cupidatat amet velit id elit consequat minim ullamco mollit enim excepteur ea.</p>
                    </div>
                </div>

                <div class="slds-modal__footer">
                    <button class="slds-button slds-button--neutral" onclick="{!c.hideModal}">Cancel</button>
                </div>
            </div>

        </div>
        <div class="slds-backdrop slds-backdrop--hide" aura:id="backdrop" />

    </div>

</aura:application>