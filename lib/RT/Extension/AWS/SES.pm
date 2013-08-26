use 5.008003;
use strict;
use warnings;

package RT::Extension::AWS::SES;

our $VERSION = '0.01';

=head1 NAME

RT::Extension::AWS::SES - Amazon Simple Email Service (SES) compatibility

=head1 DESCRIPTION

Amazon Simple Email Service (SES) (L<http://aws.amazon.com/ses/>) is a highly scalable
and cost-effective bulk and transactional email-sending service for businesses
and developers. Part of Amazon web services (AWS) infrastructure.

This RT extension helps overcome some restrictions of SES.

=head2 Email headers

SES restricts email headers to RFC822, everything else should be prefixed with 'X-'.
This is not required by newer RFCs that obsolete RFC822, but RFC822 is still called
standard while the rest are proposals or drafts.

List of allowed headers you can find in documentation -
L<http://docs.aws.amazon.com/ses/latest/DeveloperGuide/header-fields.html>.

For RT this means that some fields will be prefixed with C<X-> prefix, for example
C<RT-Ticket>. This may be important to recipients who use such headers for
automation.

=cut

our %ALLOWED_HEADERS = map { lc($_) => 1 } qw(
    Accept-Language
    acceptLanguage
    Archived-At
    Authentication-Results
    Auto-Submitted
    Bcc
    Bounces-To
    Cc
    Comments
    Content-Alternative
    Content-Class
    Content-Description
    Content-Disposition
    Content-Duration
    Content-Features
    Content-ID
    Content-Language
    Content-Length
    Content-Location
    Content-MD5
    Content-Transfer-Encoding
    Content-Type
    Date
    Disposition-Notification-Options
    Disposition-Notification-To
    DKIM-Signature
    DomainKey-Signature
    Errors-To
    From
    Importance
    In-Reply-To
    Keywords
    List-Archive
    List-Help
    List-Id
    List-Owner
    List-Post
    List-Subscribe
    List-Unsubscribe
    Message-Context
    Message-ID
    MIME-Version
    Organization
    Original-From
    Original-Message-ID
    Original-Recipient
    Original-Subject
    Precedence
    Priority
    PICS-Label
    Received
    Received-SPF
    References
    Reply-To
    Return-Path
    Return-Receipt-To
    Sender
    Solicitation
    Subject
    Thread-Index
    Thread-Topic
    To
    User-Agent
    VBR-Info
);

{
    require RT::Interface::Email;
    my $orig = RT::Interface::Email->can('SendEmail');
    no warnings 'redefine';
    *RT::Interface::Email::SendEmail = sub {
        my %args = (@_);

        foreach my $head ( map $_->head, $args{'Entity'}->parts_DFS ) {
            foreach my $tag ( $head->tags ) {
                next if $tag =~ /^x-/i;
                next if $ALLOWED_HEADERS{ lc $tag };

                my @v = $head->get($tag);
                $head->delete($tag);
                $head->add("X-$tag" => $_) foreach @v;
            }
        }
        return $orig->(%args);
    };
}

=head1 AUTHOR

Ruslan Zakirov E<lt>ruz@bestpractical.comE<gt>

=head1 LICENSE

Under the same terms as perl itself.

=cut

1;