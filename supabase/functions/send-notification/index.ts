import { createClient } from 'npm:@supabase/supabase-js@2'
import { JWT } from 'npm:google-auth-library@9'

Deno.serve(async (req) => {
  try {
    const { title, body, data } = await req.json()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SERVICE_ROLE_KEY')!
    )

    const { data: profiles, error } = await supabase
      .from('profiles')
      .select('fcm_token')
      .not('fcm_token', 'is', null)

    if (error) throw error

    const tokens = (profiles ?? [])
      .map((row) => row.fcm_token)
      .filter((token) => token)

    if (tokens.length === 0) {
      return new Response('No tokens found')
    }

    const serviceAccount = JSON.parse(
      Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!
    )

    const client = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })

    const { access_token } = await client.authorize()

    const projectId = serviceAccount.project_id

    for (const token of tokens) {
      await fetch(
        `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${access_token}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: {
              token,
              notification: {
                title,
                body,
              },
              data: data ?? {},
            },
          }),
        }
      )
    }

    return new Response(
      JSON.stringify({
        success: true,
        total_tokens: tokens.length,
      }),
      {
        headers: { 'Content-Type': 'application/json' },
      }
    )
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      {
        headers: { 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})