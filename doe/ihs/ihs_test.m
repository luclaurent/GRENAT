function ihs_test ( )

%*****************************************************************************80
%
%% IHS_TEST runs the IHS tests.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
  timestamp ( );
  fprintf ( 1, '\n' );
  fprintf ( 1, 'IHS_TEST\n' );
  fprintf ( 1, '  Test the MATLAB IHS routines.\n' );

  ihs_test01 ( );
  ihs_test02 ( );
  ihs_test03 ( );
  ihs_test04 ( );

  fprintf ( 1, '\n' );
  fprintf ( 1, 'IHS_TEST\n' );
  fprintf ( 1, '  Normal end of execution.\n' );

  fprintf ( 1, '\n' );
  timestamp ( );

  return
end
