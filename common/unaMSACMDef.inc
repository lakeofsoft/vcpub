
{$DEFINE UNA_VC_ACMCLASSES_USE_CALLBACKS }	// use callbacks rather than event notifications

{$IFDEF VC25_ENTERPRISE }
  {$DEFINE UNA_VCACM_USE_ASIO }		// link with ASIO support
{$ELSE}
{$ENDIF VC25_ENTERPRISE }

